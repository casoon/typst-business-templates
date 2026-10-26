import { statSync } from 'node:fs';
import { resolve } from 'node:path';
import { url } from '@casoon/pages-theme/lib/url.ts';
import type { ShowcaseExample } from '@casoon/pages-theme/showcase';

// Input: the example files in examples/, exactly as committed. Output: the PDF that typstgen
// compiled from that file (diagrams: chartlet spec, rendered to SVG and placed on a page), with a
// WebP of its first page. site/scripts/render-showcase.sh rebuilds public/showcase/.
const sources = import.meta.glob<string>(
  [
    '../../examples/it-consultant/documents/**/*.json',
    '../../examples/it-consultant/documents/**/*.typ',
    '../../examples/digitalagentur/documents/**/*.typ',
    '../../examples/diagrams/*.json',
    '../../examples/invoice-languages/*/invoice-config.json',
    '../../examples/publication/*.typ',
  ],
  { query: '?raw', import: 'default', eager: true }
);

function source(file: string): string {
  const found = sources[`../../${file}`];
  if (found === undefined) throw new Error(`Missing example: ${file}`);
  return found;
}

/** public/ in site/; `astro build` and `astro dev` run in site/. */
const publicDir = resolve(process.cwd(), 'public');

const portrait = { width: 778, height: 1100 };


interface Entry {
  slug: string;
  title: string;
  file: string;
  tags: string[];
  description: string;
  alt: string;
  size: { width: number; height: number };
}

/** First page as image, with links to the full PDF. */
export function preview(slug: string, alt: string, size: { width: number; height: number }): string {
  const pdf = url(`showcase/${slug}.pdf`);
  const kib = (statSync(resolve(publicDir, `showcase/${slug}.pdf`)).size / 1024).toFixed(0);
  return `<figure style="margin:0;padding:18px">
  <img src="${url(`showcase/${slug}.webp`)}" width="${size.width}" height="${size.height}" alt="${alt}" loading="lazy" decoding="async" style="display:block;width:100%;height:auto;border:1px solid var(--border);border-radius:6px;background:#fff" />
  <figcaption style="margin:12px 0 0;font-size:14px">First page, compiled by typstgen. <a href="${pdf}" style="text-decoration:underline">Open ${slug}.pdf</a> (${kib} KiB)</figcaption>
</figure>`;
}

const entries: Entry[] = [
  {
    slug: "invoice-de",
    title: "Invoice · Deutsch",
    file: "examples/invoice-languages/de/invoice-config.json",
    tags: ["invoice", "de", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Deutsch labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Deutsch with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-en",
    title: "Invoice · English",
    file: "examples/invoice-languages/en/invoice-config.json",
    tags: ["invoice", "en", "A4", "VAT", "EUR"],
    description: "Shared invoice template with English labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in English with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-fr",
    title: "Invoice · Français",
    file: "examples/invoice-languages/fr/invoice-config.json",
    tags: ["invoice", "fr", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Français labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Français with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-es",
    title: "Invoice · Español",
    file: "examples/invoice-languages/es/invoice-config.json",
    tags: ["invoice", "es", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Español labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Español with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-it",
    title: "Invoice · Italiano",
    file: "examples/invoice-languages/it/invoice-config.json",
    tags: ["invoice", "it", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Italiano labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Italiano with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-nl",
    title: "Invoice · Nederlands",
    file: "examples/invoice-languages/nl/invoice-config.json",
    tags: ["invoice", "nl", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Nederlands labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Nederlands with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-pt",
    title: "Invoice · Português",
    file: "examples/invoice-languages/pt/invoice-config.json",
    tags: ["invoice", "pt", "A4", "VAT", "EUR"],
    description: "Shared invoice template with Português labels and supplied descriptions, A4, EUR and an illustrative VAT rate. The source folder contains the invoice input and shared SVG logo.",
    alt: "Example Studio invoice in Português with SVG logo, two service lines, VAT breakdown and a total of 3358.80 EUR.",
    size: portrait,
  },
  {
    slug: "invoice-us",
    title: "Invoice · English (US)",
    file: "examples/invoice-languages/en-US/invoice-config.json",
    tags: ["invoice", "en-US", "US Letter", "sales tax", "USD"],
    description: "Shared invoice template with US Letter, USD dollar formatting, month/day/year dates and separate illustrative state/local tax components. Editable input data and SVG logo accompany the configuration.",
    alt: "Fictional Example Studio US invoice with logo, two service lines, state and local tax rows and a total of $2,994.93.",
    size: { width: 850, height: 1100 },
  },
  {
    slug: "publication-guide",
    title: "Compact guide",
    file: "examples/publication/guide.typ",
    tags: ["publication", "printable"],
    description: "Compact A4 publication with content starting on the first page, a shared header, identity metadata and flowing content.",
    alt: "First page of a fictional project guide with a compact header, sections and printable content.",
    size: portrait,
  },
  {
    slug: "publication-intake",
    title: "Printable intake form",
    file: "examples/publication/intake.typ",
    tags: ["publication", "printable"],
    description: "An A4 intake form assembled from shared writing fields, choices, notes, priorities and a table. The fields are printable, not AcroForms.",
    alt: "A fictional project intake form with labelled writing fields, checkboxes, notes and a structured table.",
    size: portrait,
  },
  {
    slug: "publication-brochure",
    title: "Landscape brochure",
    file: "examples/publication/brochure.typ",
    tags: ["publication", "printable"],
    description: "Landscape publication using shared cards, steps and notes with explicit page breaks and caller-supplied content.",
    alt: "First page of a fictional landscape brochure with cards and numbered steps.",
    size: { width: 1100, height: 778 },
  },
  {
    slug: 'invoice',
    title: 'Invoice',
    file: 'examples/it-consultant/documents/invoices/2025/invoice.json',
    tags: ['invoice', 'DIN 5008', 'VAT 19 %', 'sub-items'],
    description:
      'Five line items with sub-item descriptions, VAT breakdown and payment due date. Company details come from the example project’s company.json.',
    alt: 'German invoice RE-2025-042 from TechVision Consulting to MedTech Solutions AG: address block, five line items for an AWS cloud migration, net total 39,900.00 EUR, VAT 7,581.00 EUR, gross total 47,481.00 EUR, company footer in four columns.',
    size: portrait,
  },
  {
    slug: 'offer',
    title: 'Offer',
    file: 'examples/it-consultant/documents/offers/2025/offer.json',
    tags: ['offer', 'DIN 5008', 'validity date'],
    description: 'Six positions with a summary line and detail text each, validity date and totals.',
    alt: 'German offer AN-2025-015 from TechVision Consulting to a law firm: six positions from security assessment to documentation, gross total 26,763.10 EUR, valid until 28.02.25.',
    size: portrait,
  },
  {
    slug: 'credit-note',
    title: 'Credit note',
    file: 'examples/it-consultant/documents/credit-notes/2025/credit-note-001.json',
    tags: ['credit-note', 'reference invoice'],
    description: 'Partial cancellation that references the original invoice and states the reason.',
    alt: 'German credit note GS-2025-001 referencing invoice RE-2024-156: one position of 20 hours backend development, gross total 2,261.00 EUR.',
    size: portrait,
  },
  {
    slug: 'reminder',
    title: 'Payment reminder',
    file: 'examples/it-consultant/documents/reminders/2025/reminder-001.json',
    tags: ['reminder', 'dunning level 1'],
    description: 'First dunning level with a table of open invoices and a new payment deadline.',
    alt: 'German payment reminder M1-2025-001, dunning level 1: table with one open invoice RE-2024-189 over 4,760.00 EUR and a request to pay by 05.02.25.',
    size: portrait,
  },
  {
    slug: 'letter',
    title: 'Business letter',
    file: 'examples/it-consultant/documents/letters/2025/letter-001.json',
    tags: ['letter', 'DIN 5008', 'enclosures'],
    description: 'Formal letter with your/our reference, body text, signature and list of enclosures.',
    alt: 'German business letter BR-2025-001 from TechVision Consulting to TechVision GmbH asking for details for a web platform offer, with a bullet list, signature and two enclosures.',
    size: portrait,
  },
  {
    slug: 'quotation-request',
    title: 'Quotation request',
    file: 'examples/it-consultant/documents/quotation-requests/2025/quotation-request-001.json',
    tags: ['quotation-request', 'requirements'],
    description: 'Request to a supplier: positions with quantities, units, specifications and requirement lists.',
    alt: 'German quotation request ANF-2025-001 to CloudTech Solutions GmbH: positions for AWS support, monitoring, backup and security tools with quantities, units and requirement lists.',
    size: portrait,
  },
  {
    slug: 'credentials',
    title: 'Credentials',
    file: 'examples/it-consultant/documents/credentials/2025/credentials.json',
    tags: ['credentials', 'title page', '6 pages'],
    description:
      'Access data handover with a confidentiality notice on the title page, services with their accounts, URLs and ports.',
    alt: 'Title page of the credentials document ZD-2025-007 “AWS Cloud Infrastruktur Zugänge” for MedTech Solutions AG, with a boxed confidentiality notice and four tags.',
    size: portrait,
  },
  {
    slug: 'proposal',
    title: 'Project proposal',
    file: 'examples/it-consultant/documents/proposals/2025/proposal-001.typ',
    tags: ['proposal', 'written in Typst', '9 pages'],
    description:
      'Written in Typst on top of the proposal template: headings, lists and tables for phases, costs and risks.',
    alt: 'Title page of the project proposal PRO-2025-001 “Cloud Migration - Infrastructure Modernisierung” with a metadata box showing project, client, budget 45,000 to 65,000 EUR, timeline, status and validity.',
    size: portrait,
  },
  {
    slug: 'specification',
    title: 'Specification',
    file: 'examples/it-consultant/documents/specifications/2025/specification-001.typ',
    tags: ['specification', 'version history', '8 pages'],
    description: 'Technical specification with version, status, update date and authors on the title page.',
    alt: 'Title page of the specification SPEC-2025-001 “API Migration Spezifikation” with version 1.2, status review, creation and update dates and two authors.',
    size: portrait,
  },
  {
    slug: 'concept',
    title: 'Concept from a .typ file',
    file: 'examples/digitalagentur/documents/concepts/2025/concept.typ',
    tags: ['concept', '.typ workflow', '5 pages'],
    description:
      'Written directly in Typst: the file imports the concept template from the package and loads company.json; labels follow its language.',
    alt: 'Title page of the concept KO-2025-002 “Online-Shop Konzept Bio-Hofladen” by Pixelwerk Digitalagentur, with project, client, version, draft status and four outlined tags.',
    size: portrait,
  },
  {
    slug: 'documentation',
    title: 'Documentation from a .typ file',
    file: 'examples/digitalagentur/documents/documentation/2025/documentation.typ',
    tags: ['documentation', '.typ workflow', '6 pages'],
    description: 'A user manual in Typst markup on top of the documentation template, with the company footer on every page after the title page.',
    alt: 'Title page of the documentation DOC-2025-002 “WordPress Benutzerhandbuch” for Zimmermann Schreinerei GmbH, with project, client, version and status final in bold labels.',
    size: portrait,
  },
  {
    slug: 'diagram-flow',
    title: 'Diagram: flow',
    file: 'examples/diagrams/flow.json',
    tags: ['diagram', 'flow', 'chartlet'],
    description: 'Steps, a decision and a loop back as nodes and edges; chartlet computes the layout.',
    alt: 'Vertical flow chart “Projektfreigabe” from request through analysis and an approval decision, with a dashed loop back on “Nein”, to implementation, QA and go-live; edges are labelled.',
    size: { width: 1100, height: 903 },
  },
  {
    slug: 'diagram-timeline',
    title: 'Diagram: timeline',
    file: 'examples/diagrams/timeline.json',
    tags: ['diagram', 'timeline', 'chartlet'],
    description: 'Two phases and two milestones with dependencies on a calendar axis.',
    alt: 'Timeline “Produkt-Rollout” from January to June 2026 with the milestones kickoff and launch and the phases wireframes and implementation, linked by dependency arrows.',
    size: { width: 1100, height: 668 },
  },
  {
    slug: 'diagram-swimlane',
    title: 'Diagram: swimlane',
    file: 'examples/diagrams/swimlane.json',
    tags: ['diagram', 'swimlane', 'chartlet'],
    description: 'A chartlet flow chart with lanes: each step sits in the lane of its role.',
    alt: 'Flow chart “Support-Prozess” in three lanes for customer, support and engineering: request, ticket triage, a bug decision, bug fix, feedback and resolution.',
    size: { width: 1100, height: 517 },
  },
  {
    slug: 'diagram-quadrant',
    title: 'Diagram: quadrant',
    file: 'examples/diagrams/quadrant.json',
    tags: ['diagram', 'quadrant', 'chartlet'],
    description: 'Impact versus effort as a scatter plot with named quadrants: chartlet draws the dividing lines and the area names.',
    alt: 'Scatter plot “Feature-Priorisierung” with effort on the x axis and impact on the y axis, both from 0 to 10, divided at 5 into four named quadrants: Schnelle Erfolge, Großprojekte, Lückenfüller and Vermeiden, with four labelled features.',
    size: { width: 1100, height: 668 },
  },
  {
    slug: 'diagram-roadmap',
    title: 'Diagram: roadmap',
    file: 'examples/diagrams/roadmap.json',
    tags: ['diagram', 'roadmap', 'chartlet'],
    description: 'Three streams across 2026 as a grouped timeline, items linked within their stream.',
    alt: 'Timeline “Roadmap 2026” with three colour-coded groups Platform, Growth and Operations, two phases each across the quarters of 2026, linked by dependency arrows.',
    size: { width: 1100, height: 668 },
  },
];

export const examples: ShowcaseExample[] = entries.map(({ slug, title, file, tags, description, alt, size }) => ({
  slug,
  title,
  description,
  file,
  tags,
  input: { code: source(file), lang: file.endsWith('.typ') ? 'typst' : 'json' },
  output: { html: preview(slug, alt, size), kind: 'panel' as const },
}));

/** Lookup for the start page. */
export function example(slug: string): Entry {
  const found = entries.find((e) => e.slug === slug);
  if (found === undefined) throw new Error(`Unknown example: ${slug}`);
  return found;
}
