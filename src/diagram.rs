use std::collections::{BTreeMap, HashMap, HashSet, VecDeque};

use anyhow::{anyhow, bail, Context, Result};
use serde::{Deserialize, Serialize};

const DEFAULT_PAGE_WIDTH_PT: f64 = 960.0;
const DEFAULT_PAGE_HEIGHT_PT: f64 = 540.0;
const DEFAULT_MARGIN_PT: f64 = 28.0;
const DEFAULT_HEADER_HEIGHT_PT: f64 = 64.0;
const DEFAULT_NODE_GAP_PT: f64 = 28.0;
const DEFAULT_LAYER_GAP_PT: f64 = 92.0;
const DEFAULT_RADIAL_STEP_PT: f64 = 128.0;

#[derive(Debug, Clone, Deserialize)]
pub struct DiagramSpec {
    #[serde(default)]
    pub document: DocumentSpec,
    #[serde(default)]
    pub diagram: DiagramMeta,
    #[serde(default)]
    pub nodes: Vec<NodeSpec>,
    #[serde(default)]
    pub edges: Vec<EdgeSpec>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct DocumentSpec {
    pub paper: Option<String>,
    pub width: Option<String>,
    pub height: Option<String>,
    pub flipped: Option<bool>,
    pub margin: Option<String>,
    pub background: Option<String>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct DiagramMeta {
    pub kind: Option<String>,
    pub layout: Option<String>,
    pub direction: Option<String>,
    pub title: Option<String>,
    pub subtitle: Option<String>,
    pub theme: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct NodeSpec {
    pub id: String,
    pub label: String,
    pub shape: Option<String>,
    pub parent: Option<String>,
    #[serde(default)]
    pub style: NodeStyle,
}

#[derive(Debug, Clone, Deserialize)]
pub struct EdgeSpec {
    pub from: String,
    pub to: String,
    pub label: Option<String>,
    pub kind: Option<String>,
    #[serde(default)]
    pub style: EdgeStyle,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct NodeStyle {
    pub fill: Option<String>,
    pub stroke: Option<String>,
    pub text: Option<String>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct EdgeStyle {
    pub stroke: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct DiagramRenderModel {
    document: RenderDocument,
    diagram: RenderDiagramMeta,
    nodes: Vec<RenderNode>,
    edges: Vec<RenderEdge>,
}

#[derive(Debug, Clone, Serialize)]
struct RenderDocument {
    width_pt: f64,
    height_pt: f64,
    margin_pt: f64,
    header_height_pt: f64,
    background: String,
}

#[derive(Debug, Clone, Serialize)]
struct RenderDiagramMeta {
    kind: String,
    layout: String,
    direction: String,
    title: Option<String>,
    subtitle: Option<String>,
    theme: String,
}

#[derive(Debug, Clone, Serialize)]
struct RenderNode {
    id: String,
    label: String,
    shape: String,
    x_pt: f64,
    y_pt: f64,
    width_pt: f64,
    height_pt: f64,
    fill: String,
    stroke: String,
    text: String,
}

#[derive(Debug, Clone, Serialize)]
struct RenderEdge {
    from: String,
    to: String,
    label: Option<String>,
    stroke: String,
    segments: Vec<RenderSegment>,
    arrow_x_pt: f64,
    arrow_y_pt: f64,
    arrow_angle_deg: f64,
    label_x_pt: f64,
    label_y_pt: f64,
}

#[derive(Debug, Clone, Serialize)]
struct RenderSegment {
    start_x_pt: f64,
    start_y_pt: f64,
    end_x_pt: f64,
    end_y_pt: f64,
}

#[derive(Debug, Clone)]
struct MeasuredNode {
    spec: NodeSpec,
    width_pt: f64,
    height_pt: f64,
}

#[derive(Debug, Clone, Default)]
struct NodePlacement {
    center_x: f64,
    center_y: f64,
}

#[derive(Debug, Clone)]
struct WorkingEdge {
    spec: EdgeSpec,
    points: Vec<(f64, f64)>,
}

pub fn preprocess_diagram_data(data: &[u8]) -> Result<Vec<u8>> {
    let spec: DiagramSpec = serde_json::from_slice(data).context("Failed to parse diagram JSON")?;
    let render = build_render_model(spec)?;
    serde_json::to_vec(&render).context("Failed to serialize diagram render model")
}

fn build_render_model(spec: DiagramSpec) -> Result<DiagramRenderModel> {
    validate_spec(&spec)?;

    let doc = resolve_document(
        &spec.document,
        spec.diagram.title.is_some() || spec.diagram.subtitle.is_some(),
    )?;
    let layout = resolve_layout(&spec.diagram);
    let direction = spec
        .diagram
        .direction
        .clone()
        .unwrap_or_else(|| "top-down".to_string());
    let theme = spec
        .diagram
        .theme
        .clone()
        .unwrap_or_else(|| "default".to_string());

    let measured = measure_nodes(&spec.nodes);
    let node_index: HashMap<&str, usize> = measured
        .iter()
        .enumerate()
        .map(|(idx, node)| (node.spec.id.as_str(), idx))
        .collect();

    let placements = match layout.as_str() {
        "radial" => layout_radial(&measured, &spec.edges, &node_index),
        "layered" => layout_layered(&measured, &spec.edges, &node_index),
        _ => layout_hierarchical(&measured, &spec.edges, &node_index),
    }?;

    let mut nodes = measured
        .iter()
        .map(|node| {
            let placement = placements
                .get(node.spec.id.as_str())
                .ok_or_else(|| anyhow!("Missing placement for node '{}'", node.spec.id))?;
            Ok((
                node.spec.id.clone(),
                PositionedNode {
                    label: node.spec.label.clone(),
                    shape: normalize_shape(node.spec.shape.as_deref()),
                    center_x: placement.center_x,
                    center_y: placement.center_y,
                    width_pt: node.width_pt,
                    height_pt: node.height_pt,
                    fill: node
                        .spec
                        .style
                        .fill
                        .clone()
                        .unwrap_or_else(|| "#ffffff".to_string()),
                    stroke: node
                        .spec
                        .style
                        .stroke
                        .clone()
                        .unwrap_or_else(|| "#334155".to_string()),
                    text: node
                        .spec
                        .style
                        .text
                        .clone()
                        .unwrap_or_else(|| "#0f172a".to_string()),
                },
            ))
        })
        .collect::<Result<HashMap<_, _>>>()?;

    let mut edges = build_edges(&spec.edges, &nodes, &layout)?;
    normalize_to_page(&doc, &mut nodes, &mut edges);
    apply_direction(&direction, &doc, &mut nodes, &mut edges);

    let render_nodes = measured
        .iter()
        .map(|node| {
            let positioned = nodes.get(&node.spec.id).unwrap();
            RenderNode {
                id: node.spec.id.clone(),
                label: positioned.label.clone(),
                shape: positioned.shape.clone(),
                x_pt: positioned.center_x - positioned.width_pt / 2.0,
                y_pt: positioned.center_y - positioned.height_pt / 2.0,
                width_pt: positioned.width_pt,
                height_pt: positioned.height_pt,
                fill: positioned.fill.clone(),
                stroke: positioned.stroke.clone(),
                text: positioned.text.clone(),
            }
        })
        .collect();

    let render_edges = edges
        .into_iter()
        .map(|edge| {
            let ((sx, sy), (ex, ey)) = edge
                .points
                .split_first()
                .and_then(|(first, rest)| rest.last().map(|last| (*first, *last)))
                .ok_or_else(|| {
                    anyhow!(
                        "Edge '{}' -> '{}' has no points",
                        edge.spec.from,
                        edge.spec.to
                    )
                })?;
            let label_point = point_at_ratio(&edge.points, 0.5);
            let angle = (ey - sy).atan2(ex - sx).to_degrees();
            let segments = edge
                .points
                .windows(2)
                .map(|w| RenderSegment {
                    start_x_pt: w[0].0,
                    start_y_pt: w[0].1,
                    end_x_pt: w[1].0,
                    end_y_pt: w[1].1,
                })
                .collect();

            Ok(RenderEdge {
                from: edge.spec.from,
                to: edge.spec.to,
                label: edge.spec.label,
                stroke: edge
                    .spec
                    .style
                    .stroke
                    .unwrap_or_else(|| "#64748b".to_string()),
                segments,
                arrow_x_pt: ex,
                arrow_y_pt: ey,
                arrow_angle_deg: angle,
                label_x_pt: label_point.0,
                label_y_pt: label_point.1,
            })
        })
        .collect::<Result<Vec<_>>>()?;

    Ok(DiagramRenderModel {
        document: RenderDocument {
            width_pt: doc.width_pt,
            height_pt: doc.height_pt,
            margin_pt: doc.margin_pt,
            header_height_pt: doc.header_height_pt,
            background: doc.background,
        },
        diagram: RenderDiagramMeta {
            kind: spec.diagram.kind.unwrap_or_else(|| "diagram".to_string()),
            layout,
            direction,
            title: spec.diagram.title,
            subtitle: spec.diagram.subtitle,
            theme,
        },
        nodes: render_nodes,
        edges: render_edges,
    })
}

#[derive(Debug, Clone)]
struct PositionedNode {
    label: String,
    shape: String,
    center_x: f64,
    center_y: f64,
    width_pt: f64,
    height_pt: f64,
    fill: String,
    stroke: String,
    text: String,
}

#[derive(Debug, Clone)]
struct ResolvedDocument {
    width_pt: f64,
    height_pt: f64,
    margin_pt: f64,
    header_height_pt: f64,
    background: String,
}

fn validate_spec(spec: &DiagramSpec) -> Result<()> {
    if spec.nodes.is_empty() {
        bail!("Diagram requires at least one node");
    }

    let mut ids = HashSet::new();
    for node in &spec.nodes {
        if !ids.insert(node.id.clone()) {
            bail!("Duplicate node id '{}'", node.id);
        }
    }

    for edge in &spec.edges {
        if !ids.contains(&edge.from) {
            bail!("Edge references unknown source node '{}'", edge.from);
        }
        if !ids.contains(&edge.to) {
            bail!("Edge references unknown target node '{}'", edge.to);
        }
    }

    for node in &spec.nodes {
        if let Some(parent) = &node.parent {
            if !ids.contains(parent) {
                bail!("Node '{}' references unknown parent '{}'", node.id, parent);
            }
        }
    }

    Ok(())
}

fn resolve_document(document: &DocumentSpec, has_header: bool) -> Result<ResolvedDocument> {
    let (mut width_pt, mut height_pt) =
        if let (Some(width), Some(height)) = (&document.width, &document.height) {
            (parse_length(width)?, parse_length(height)?)
        } else if let Some(paper) = &document.paper {
            paper_size(paper).ok_or_else(|| anyhow!("Unsupported paper format '{}'", paper))?
        } else {
            (DEFAULT_PAGE_WIDTH_PT, DEFAULT_PAGE_HEIGHT_PT)
        };

    if document.flipped.unwrap_or(false) {
        std::mem::swap(&mut width_pt, &mut height_pt);
    }

    let margin_pt = document
        .margin
        .as_deref()
        .map(parse_length)
        .transpose()?
        .unwrap_or(DEFAULT_MARGIN_PT);
    let header_height_pt = if has_header {
        DEFAULT_HEADER_HEIGHT_PT
    } else {
        0.0
    };

    Ok(ResolvedDocument {
        width_pt,
        height_pt,
        margin_pt,
        header_height_pt,
        background: document
            .background
            .clone()
            .unwrap_or_else(|| "#f8fafc".to_string()),
    })
}

fn resolve_layout(diagram: &DiagramMeta) -> String {
    if let Some(layout) = &diagram.layout {
        return normalize_layout(layout);
    }

    match diagram.kind.as_deref() {
        Some("mindmap") => "radial".to_string(),
        Some("flow") | Some("architecture") => "layered".to_string(),
        _ => "hierarchical".to_string(),
    }
}

fn normalize_layout(layout: &str) -> String {
    match layout {
        "tree" | "hierarchical" => "hierarchical".to_string(),
        "flow" | "layered" => "layered".to_string(),
        "mindmap" | "radial" => "radial".to_string(),
        other => other.to_string(),
    }
}

fn normalize_shape(shape: Option<&str>) -> String {
    match shape.unwrap_or("rounded") {
        "rect" | "rectangle" => "rect".to_string(),
        "diamond" => "diamond".to_string(),
        "circle" => "circle".to_string(),
        _ => "rounded".to_string(),
    }
}

fn measure_nodes(nodes: &[NodeSpec]) -> Vec<MeasuredNode> {
    nodes
        .iter()
        .map(|node| {
            let label_len = node.label.chars().count().max(1) as f64;
            let max_width = 190.0;
            let estimated_width = (label_len * 6.9 + 30.0).clamp(72.0, max_width);
            let line_count = (label_len * 6.9 / estimated_width).ceil().max(1.0);
            let height = (line_count * 16.0 + 24.0).clamp(36.0, 120.0);
            let shape = normalize_shape(node.shape.as_deref());
            let (width_pt, height_pt) = if shape == "circle" {
                let size = estimated_width.max(height);
                (size, size)
            } else if shape == "diamond" {
                (estimated_width.max(92.0), height.max(64.0))
            } else {
                (estimated_width, height)
            };

            MeasuredNode {
                spec: node.clone(),
                width_pt,
                height_pt,
            }
        })
        .collect()
}

fn layout_hierarchical(
    nodes: &[MeasuredNode],
    edges: &[EdgeSpec],
    node_index: &HashMap<&str, usize>,
) -> Result<HashMap<String, NodePlacement>> {
    let children = directed_children(nodes, edges);
    let root = find_root(nodes, edges).unwrap_or_else(|| nodes[0].spec.id.clone());
    let max_height = nodes.iter().map(|node| node.height_pt).fold(0.0, f64::max);

    let mut subtree_spans = HashMap::new();
    compute_tree_spans(
        &root,
        &children,
        nodes,
        node_index,
        &mut subtree_spans,
        &mut HashSet::new(),
    );

    let total_span = *subtree_spans
        .get(&root)
        .unwrap_or(&nodes[node_index[&root.as_str()]].width_pt);
    let mut placements = HashMap::new();
    place_tree(
        &root,
        0.0,
        total_span,
        0,
        &children,
        nodes,
        node_index,
        &subtree_spans,
        max_height + DEFAULT_LAYER_GAP_PT,
        &mut placements,
        &mut HashSet::new(),
    );

    Ok(placements)
}

fn compute_tree_spans(
    node_id: &str,
    children: &HashMap<String, Vec<String>>,
    nodes: &[MeasuredNode],
    node_index: &HashMap<&str, usize>,
    spans: &mut HashMap<String, f64>,
    visited: &mut HashSet<String>,
) -> f64 {
    if !visited.insert(node_id.to_string()) {
        return nodes[node_index[node_id]].width_pt;
    }

    let own_width = nodes[node_index[node_id]].width_pt;
    let child_ids = children.get(node_id).cloned().unwrap_or_default();
    if child_ids.is_empty() {
        spans.insert(node_id.to_string(), own_width);
        return own_width;
    }

    let mut total = 0.0;
    for (idx, child) in child_ids.iter().enumerate() {
        if idx > 0 {
            total += DEFAULT_NODE_GAP_PT;
        }
        total += compute_tree_spans(child, children, nodes, node_index, spans, visited);
    }
    total = total.max(own_width);
    spans.insert(node_id.to_string(), total);
    total
}

#[allow(clippy::too_many_arguments)]
fn place_tree(
    node_id: &str,
    x_start: f64,
    span: f64,
    depth: usize,
    children: &HashMap<String, Vec<String>>,
    nodes: &[MeasuredNode],
    node_index: &HashMap<&str, usize>,
    spans: &HashMap<String, f64>,
    layer_step: f64,
    placements: &mut HashMap<String, NodePlacement>,
    visited: &mut HashSet<String>,
) {
    if !visited.insert(node_id.to_string()) {
        return;
    }

    let measured = &nodes[node_index[node_id]];
    placements.insert(
        node_id.to_string(),
        NodePlacement {
            center_x: x_start + span / 2.0,
            center_y: depth as f64 * layer_step + measured.height_pt / 2.0,
        },
    );

    let child_ids = children.get(node_id).cloned().unwrap_or_default();
    let total_children_span: f64 = child_ids
        .iter()
        .enumerate()
        .map(|(idx, child)| {
            spans.get(child).copied().unwrap_or(0.0)
                + if idx > 0 { DEFAULT_NODE_GAP_PT } else { 0.0 }
        })
        .sum();
    let mut cursor = x_start + (span - total_children_span.max(0.0)) / 2.0;

    for child in child_ids {
        let child_span = spans
            .get(&child)
            .copied()
            .unwrap_or(nodes[node_index[child.as_str()]].width_pt);
        place_tree(
            &child,
            cursor,
            child_span,
            depth + 1,
            children,
            nodes,
            node_index,
            spans,
            layer_step,
            placements,
            visited,
        );
        cursor += child_span + DEFAULT_NODE_GAP_PT;
    }
}

fn layout_layered(
    nodes: &[MeasuredNode],
    edges: &[EdgeSpec],
    _node_index: &HashMap<&str, usize>,
) -> Result<HashMap<String, NodePlacement>> {
    let mut indegree = HashMap::new();
    let mut outgoing: HashMap<String, Vec<String>> = HashMap::new();
    for node in nodes {
        indegree.insert(node.spec.id.clone(), 0usize);
    }
    for edge in edges {
        *indegree.entry(edge.to.clone()).or_default() += 1;
        outgoing
            .entry(edge.from.clone())
            .or_default()
            .push(edge.to.clone());
    }

    for node in nodes {
        if let Some(parent) = &node.spec.parent {
            *indegree.entry(node.spec.id.clone()).or_default() += 1;
            outgoing
                .entry(parent.clone())
                .or_default()
                .push(node.spec.id.clone());
        }
    }

    let mut queue: VecDeque<String> = indegree
        .iter()
        .filter(|(_, degree)| **degree == 0)
        .map(|(id, _)| id.clone())
        .collect();
    if queue.is_empty() {
        queue.push_back(nodes[0].spec.id.clone());
    }

    let mut layer = HashMap::new();
    while let Some(node_id) = queue.pop_front() {
        let current_layer = layer.get(&node_id).copied().unwrap_or(0usize);
        for child in outgoing.get(&node_id).cloned().unwrap_or_default() {
            let next = current_layer + 1;
            if layer.get(&child).copied().unwrap_or(0) < next {
                layer.insert(child.clone(), next);
            }
            if let Some(degree) = indegree.get_mut(&child) {
                if *degree > 0 {
                    *degree -= 1;
                    if *degree == 0 {
                        queue.push_back(child);
                    }
                }
            }
        }
    }

    for node in nodes {
        layer.entry(node.spec.id.clone()).or_insert(0);
    }

    let mut groups: BTreeMap<usize, Vec<&MeasuredNode>> = BTreeMap::new();
    for node in nodes {
        groups
            .entry(*layer.get(&node.spec.id).unwrap_or(&0))
            .or_default()
            .push(node);
    }

    let mut placements = HashMap::new();
    let max_width = groups
        .values()
        .map(|group| {
            group
                .iter()
                .enumerate()
                .map(|(idx, node)| node.width_pt + if idx > 0 { DEFAULT_NODE_GAP_PT } else { 0.0 })
                .sum::<f64>()
        })
        .fold(0.0, f64::max);

    let mut y = 0.0;
    for group in groups.values() {
        let group_height = group.iter().map(|node| node.height_pt).fold(0.0, f64::max);
        let total_width: f64 = group
            .iter()
            .enumerate()
            .map(|(idx, node)| node.width_pt + if idx > 0 { DEFAULT_NODE_GAP_PT } else { 0.0 })
            .sum();
        let mut cursor = (max_width - total_width) / 2.0;
        for node in group {
            placements.insert(
                node.spec.id.clone(),
                NodePlacement {
                    center_x: cursor + node.width_pt / 2.0,
                    center_y: y + group_height / 2.0,
                },
            );
            cursor += node.width_pt + DEFAULT_NODE_GAP_PT;
        }
        y += group_height + DEFAULT_LAYER_GAP_PT;
    }

    Ok(placements)
}

fn layout_radial(
    nodes: &[MeasuredNode],
    edges: &[EdgeSpec],
    node_index: &HashMap<&str, usize>,
) -> Result<HashMap<String, NodePlacement>> {
    let root = find_root(nodes, edges).unwrap_or_else(|| nodes[0].spec.id.clone());
    let graph = undirected_graph(nodes, edges);
    let tree = bfs_tree(&root, &graph);
    let mut placements = HashMap::new();
    let mut leaf_counts = HashMap::new();
    compute_leaf_counts(&root, &tree, &mut leaf_counts);

    place_radial(&root, 0, -90.0, 270.0, &tree, &leaf_counts, &mut placements);

    for (node_id, placement) in &mut placements {
        let measured = &nodes[node_index[node_id.as_str()]];
        placement.center_x += measured.width_pt / 2.0;
        placement.center_y += measured.height_pt / 2.0;
    }

    Ok(placements)
}

fn compute_leaf_counts(
    node_id: &str,
    tree: &HashMap<String, Vec<String>>,
    counts: &mut HashMap<String, usize>,
) -> usize {
    let children = tree.get(node_id).cloned().unwrap_or_default();
    if children.is_empty() {
        counts.insert(node_id.to_string(), 1);
        return 1;
    }

    let total = children
        .iter()
        .map(|child| compute_leaf_counts(child, tree, counts))
        .sum::<usize>()
        .max(1);
    counts.insert(node_id.to_string(), total);
    total
}

fn place_radial(
    node_id: &str,
    depth: usize,
    start_deg: f64,
    end_deg: f64,
    tree: &HashMap<String, Vec<String>>,
    leaf_counts: &HashMap<String, usize>,
    placements: &mut HashMap<String, NodePlacement>,
) {
    let angle = (start_deg + end_deg) / 2.0;
    let radius = depth as f64 * DEFAULT_RADIAL_STEP_PT;
    let radians = angle.to_radians();
    placements.insert(
        node_id.to_string(),
        NodePlacement {
            center_x: radius * radians.cos(),
            center_y: radius * radians.sin(),
        },
    );

    let children = tree.get(node_id).cloned().unwrap_or_default();
    if children.is_empty() {
        return;
    }

    let total = children
        .iter()
        .map(|child| *leaf_counts.get(child).unwrap_or(&1))
        .sum::<usize>()
        .max(1) as f64;
    let mut cursor = start_deg;
    for child in children {
        let span = (end_deg - start_deg) * (*leaf_counts.get(&child).unwrap_or(&1) as f64 / total);
        place_radial(
            &child,
            depth + 1,
            cursor,
            cursor + span,
            tree,
            leaf_counts,
            placements,
        );
        cursor += span;
    }
}

fn build_edges(
    specs: &[EdgeSpec],
    nodes: &HashMap<String, PositionedNode>,
    layout: &str,
) -> Result<Vec<WorkingEdge>> {
    specs
        .iter()
        .map(|edge| {
            let from = nodes
                .get(&edge.from)
                .ok_or_else(|| anyhow!("Missing node '{}'", edge.from))?;
            let to = nodes
                .get(&edge.to)
                .ok_or_else(|| anyhow!("Missing node '{}'", edge.to))?;
            let points = if layout == "radial"
                || matches!(edge.kind.as_deref(), Some("direct") | Some("straight"))
            {
                vec![(from.center_x, from.center_y), (to.center_x, to.center_y)]
            } else {
                let from_bottom = from.center_y <= to.center_y;
                let start = (
                    from.center_x,
                    if from_bottom {
                        from.center_y + from.height_pt / 2.0
                    } else {
                        from.center_y - from.height_pt / 2.0
                    },
                );
                let end = (
                    to.center_x,
                    if from_bottom {
                        to.center_y - to.height_pt / 2.0
                    } else {
                        to.center_y + to.height_pt / 2.0
                    },
                );
                let mid_y = (start.1 + end.1) / 2.0;
                vec![start, (start.0, mid_y), (end.0, mid_y), end]
            };

            Ok(WorkingEdge {
                spec: edge.clone(),
                points,
            })
        })
        .collect()
}

fn normalize_to_page(
    doc: &ResolvedDocument,
    nodes: &mut HashMap<String, PositionedNode>,
    edges: &mut [WorkingEdge],
) {
    let mut min_x = f64::MAX;
    let mut min_y = f64::MAX;
    let mut max_x = f64::MIN;
    let mut max_y = f64::MIN;

    for node in nodes.values() {
        min_x = min_x.min(node.center_x - node.width_pt / 2.0);
        min_y = min_y.min(node.center_y - node.height_pt / 2.0);
        max_x = max_x.max(node.center_x + node.width_pt / 2.0);
        max_y = max_y.max(node.center_y + node.height_pt / 2.0);
    }

    for edge in edges.iter() {
        for point in &edge.points {
            min_x = min_x.min(point.0);
            min_y = min_y.min(point.1);
            max_x = max_x.max(point.0);
            max_y = max_y.max(point.1);
        }
    }

    let width = (max_x - min_x).max(1.0);
    let height = (max_y - min_y).max(1.0);
    let available_width = (doc.width_pt - doc.margin_pt * 2.0).max(120.0);
    let available_height = (doc.height_pt - doc.margin_pt * 2.0 - doc.header_height_pt).max(120.0);
    let scale = (available_width / width)
        .min(available_height / height)
        .min(1.0);

    let offset_x = doc.margin_pt + (available_width - width * scale) / 2.0;
    let offset_y = doc.margin_pt + doc.header_height_pt + (available_height - height * scale) / 2.0;

    for node in nodes.values_mut() {
        node.center_x = offset_x + (node.center_x - min_x) * scale;
        node.center_y = offset_y + (node.center_y - min_y) * scale;
        node.width_pt *= scale;
        node.height_pt *= scale;
    }

    for edge in edges.iter_mut() {
        for point in &mut edge.points {
            point.0 = offset_x + (point.0 - min_x) * scale;
            point.1 = offset_y + (point.1 - min_y) * scale;
        }
    }
}

fn apply_direction(
    direction: &str,
    doc: &ResolvedDocument,
    nodes: &mut HashMap<String, PositionedNode>,
    edges: &mut [WorkingEdge],
) {
    if direction != "left-right" {
        return;
    }

    let content_origin_x = doc.margin_pt;
    let content_origin_y = doc.margin_pt + doc.header_height_pt;
    let content_width = doc.width_pt - doc.margin_pt * 2.0;
    let content_height = doc.height_pt - doc.margin_pt * 2.0 - doc.header_height_pt;

    for node in nodes.values_mut() {
        let rel_x = node.center_x - content_origin_x;
        let rel_y = node.center_y - content_origin_y;
        node.center_x = content_origin_x + rel_y;
        node.center_y = content_origin_y + (content_height - rel_x).clamp(0.0, content_height);
        std::mem::swap(&mut node.width_pt, &mut node.height_pt);
    }

    for edge in edges.iter_mut() {
        for point in &mut edge.points {
            let rel_x = point.0 - content_origin_x;
            let rel_y = point.1 - content_origin_y;
            point.0 = content_origin_x + rel_y;
            point.1 = content_origin_y + (content_height - rel_x).clamp(0.0, content_height);
        }
    }

    let _ = content_width;
}

fn directed_children(nodes: &[MeasuredNode], edges: &[EdgeSpec]) -> HashMap<String, Vec<String>> {
    let mut map: HashMap<String, Vec<String>> = HashMap::new();
    for node in nodes {
        if let Some(parent) = &node.spec.parent {
            map.entry(parent.clone())
                .or_default()
                .push(node.spec.id.clone());
        }
    }
    for edge in edges {
        map.entry(edge.from.clone())
            .or_default()
            .push(edge.to.clone());
    }
    map
}

fn undirected_graph(nodes: &[MeasuredNode], edges: &[EdgeSpec]) -> HashMap<String, Vec<String>> {
    let mut graph = HashMap::new();
    for node in nodes {
        graph.entry(node.spec.id.clone()).or_insert_with(Vec::new);
        if let Some(parent) = &node.spec.parent {
            graph
                .entry(node.spec.id.clone())
                .or_default()
                .push(parent.clone());
            graph
                .entry(parent.clone())
                .or_default()
                .push(node.spec.id.clone());
        }
    }
    for edge in edges {
        graph
            .entry(edge.from.clone())
            .or_default()
            .push(edge.to.clone());
        graph
            .entry(edge.to.clone())
            .or_default()
            .push(edge.from.clone());
    }
    graph
}

fn bfs_tree(root: &str, graph: &HashMap<String, Vec<String>>) -> HashMap<String, Vec<String>> {
    let mut queue = VecDeque::from([root.to_string()]);
    let mut visited = HashSet::from([root.to_string()]);
    let mut tree: HashMap<String, Vec<String>> = HashMap::new();

    while let Some(node) = queue.pop_front() {
        for next in graph.get(&node).cloned().unwrap_or_default() {
            if visited.insert(next.clone()) {
                tree.entry(node.clone()).or_default().push(next.clone());
                queue.push_back(next);
            }
        }
    }

    tree
}

fn find_root(nodes: &[MeasuredNode], edges: &[EdgeSpec]) -> Option<String> {
    let mut incoming: HashMap<String, usize> = nodes
        .iter()
        .map(|node| (node.spec.id.clone(), 0usize))
        .collect();
    for edge in edges {
        *incoming.entry(edge.to.clone()).or_default() += 1;
    }
    for node in nodes {
        if node.spec.parent.is_some() {
            *incoming.entry(node.spec.id.clone()).or_default() += 1;
        }
    }
    incoming
        .into_iter()
        .find(|(_, count)| *count == 0)
        .map(|(id, _)| id)
}

fn point_at_ratio(points: &[(f64, f64)], ratio: f64) -> (f64, f64) {
    if points.len() < 2 {
        return points.first().copied().unwrap_or((0.0, 0.0));
    }

    let segments = points
        .windows(2)
        .map(|window| {
            let dx = window[1].0 - window[0].0;
            let dy = window[1].1 - window[0].1;
            (window[0], window[1], (dx * dx + dy * dy).sqrt())
        })
        .collect::<Vec<_>>();
    let total = segments.iter().map(|(_, _, len)| len).sum::<f64>().max(1.0);
    let target = total * ratio.clamp(0.0, 1.0);
    let mut walked = 0.0;

    for (start, end, len) in segments {
        if walked + len >= target {
            let local = (target - walked) / len.max(1.0);
            return (
                start.0 + (end.0 - start.0) * local,
                start.1 + (end.1 - start.1) * local,
            );
        }
        walked += len;
    }

    points.last().copied().unwrap_or((0.0, 0.0))
}

fn paper_size(name: &str) -> Option<(f64, f64)> {
    match name {
        "a4" => Some((595.28, 841.89)),
        "a3" => Some((841.89, 1190.55)),
        "a5" => Some((419.53, 595.28)),
        "presentation-16-9" => Some((960.0, 540.0)),
        "presentation-4-3" => Some((960.0, 720.0)),
        _ => None,
    }
}

fn parse_length(value: &str) -> Result<f64> {
    let trimmed = value.trim().to_lowercase();
    let parse = |suffix: &str, factor: f64| -> Option<Result<f64>> {
        trimmed.strip_suffix(suffix).map(|raw| {
            raw.trim()
                .parse::<f64>()
                .map(|num| num * factor)
                .map_err(|err| anyhow!(err))
        })
    };

    if let Some(result) = parse("pt", 1.0) {
        return result;
    }
    if let Some(result) = parse("mm", 72.0 / 25.4) {
        return result;
    }
    if let Some(result) = parse("cm", 72.0 / 2.54) {
        return result;
    }
    if let Some(result) = parse("in", 72.0) {
        return result;
    }

    trimmed
        .parse::<f64>()
        .map_err(|_| anyhow!("Unsupported length '{}'", value))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn preprocesses_tree_diagram() {
        let input = r#"
        {
          "document": { "paper": "presentation-16-9" },
          "diagram": { "kind": "tree", "title": "Org Chart" },
          "nodes": [
            { "id": "root", "label": "CEO" },
            { "id": "a", "label": "Product", "parent": "root" },
            { "id": "b", "label": "Engineering", "parent": "root" }
          ],
          "edges": [
            { "from": "root", "to": "a" },
            { "from": "root", "to": "b" }
          ]
        }"#;

        let output = preprocess_diagram_data(input.as_bytes()).unwrap();
        let rendered: serde_json::Value = serde_json::from_slice(&output).unwrap();
        assert_eq!(rendered["nodes"].as_array().unwrap().len(), 3);
        assert_eq!(rendered["edges"].as_array().unwrap().len(), 2);
    }

    #[test]
    fn parses_lengths() {
        assert_eq!(parse_length("10pt").unwrap(), 10.0);
        assert!(parse_length("20mm").unwrap() > 50.0);
        assert!(parse_length("bad").is_err());
    }
}
