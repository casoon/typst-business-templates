import { statSync } from 'node:fs';
import { resolve } from 'node:path';
import { url } from '@casoon/pages-theme/lib/url.ts';
import type { ShowcaseExample } from '@casoon/pages-theme/showcase';

// Input: the example files in examples/, exactly as committed. Output: the PDF that docgen
// compiled from that file, with a WebP of its first page. site/scripts/render-showcase.sh
// rebuilds public/showcase/ with the docgen CLI of this checkout.
const sources = import.meta.glob<string>(
  [
    '../../examples/it-consultant/documents/**/*.json',
    '../../examples/digitalagentur/documents/**/*.typ',
    '../../examples/diagram-*/diagram.json',
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
const landscape = { width: 1100, height: 619 };

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
  <figcaption style="margin:12px 0 0;font-size:14px">First page, compiled by docgen. <a href="${pdf}" style="text-decoration:underline">Open ${slug}.pdf</a> (${kib} KiB)</figcaption>
</figure>`;
}

const entries: Entry[] = [
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
      'Access data handover with a confidentiality notice on the title page. docgen compile --encrypt protects such a PDF with a password (needs qpdf).',
    alt: 'Title page of the credentials document ZD-2025-007 “AWS Cloud Infrastruktur Zugänge” for MedTech Solutions AG, with a boxed confidentiality notice and four tags.',
    size: portrait,
  },
  {
    slug: 'proposal',
    title: 'Project proposal',
    file: 'examples/it-consultant/documents/proposals/2025/proposal-001.json',
    tags: ['proposal', 'Typst markup in JSON', '9 pages'],
    description:
      'The body is Typst markup inside the JSON content field: headings, lists and tables for phases, costs and risks.',
    alt: 'Title page of the project proposal PRO-2025-001 “Cloud Migration - Infrastructure Modernisierung” with a metadata box showing project, client, budget 45,000 to 65,000 EUR, timeline, status and validity.',
    size: portrait,
  },
  {
    slug: 'specification',
    title: 'Specification',
    file: 'examples/it-consultant/documents/specifications/2025/specification-001.json',
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
      'Written directly in Typst: the file imports the concept template from .docgen/templates/ and loads company.json and the locale.',
    alt: 'Title page of the concept KO-2025-002 “Online-Shop Konzept Bio-Hofladen” by Pixelwerk Digitalagentur, with project, client, version, draft status and four tags in orange.',
    size: portrait,
  },
  {
    slug: 'documentation',
    title: 'Documentation from a .typ file',
    file: 'examples/digitalagentur/documents/documentation/2025/documentation.typ',
    tags: ['documentation', '.typ workflow', '6 pages'],
    description: 'A user manual in Typst markup on top of the documentation template, with footer on every page.',
    alt: 'Title page of the documentation DOC-2025-002 “WordPress Benutzerhandbuch” for Zimmermann Schreinerei GmbH, status final, with a four-column company footer.',
    size: portrait,
  },
  {
    slug: 'diagram-flow',
    title: 'Diagram: flow',
    file: 'examples/diagram-flow/diagram.json',
    tags: ['diagram', 'flow', 'no positioning'],
    description: 'Nodes and edges only; docgen computes the layered layout. No coordinates in the JSON.',
    alt: 'Vertical flow diagram “Projektfreigabe” from request through analysis, an approval decision diamond, implementation and QA to go-live, with labelled edges.',
    size: landscape,
  },
  {
    slug: 'diagram-timeline',
    title: 'Diagram: timeline',
    file: 'examples/diagram-timeline/diagram.json',
    tags: ['diagram', 'timeline'],
    description: 'Four phases on a horizontal axis, milestones placed by phase.',
    alt: 'Timeline diagram “Produkt-Rollout” with the phases kickoff, design, build and launch and one milestone in each.',
    size: landscape,
  },
  {
    slug: 'diagram-swimlane',
    title: 'Diagram: swimlane',
    file: 'examples/diagram-swimlane/diagram.json',
    tags: ['diagram', 'swimlane'],
    description: 'A process across three roles; each step sits in its lane, edges cross lanes.',
    alt: 'Swimlane diagram “Support-Prozess” with lanes for customer, support and engineering: request, ticket triage, bug fix and feedback, connected by edges.',
    size: landscape,
  },
  {
    slug: 'diagram-quadrant',
    title: 'Diagram: quadrant',
    file: 'examples/diagram-quadrant/diagram.json',
    tags: ['diagram', 'quadrant'],
    description: 'Impact versus effort matrix with one item per quadrant.',
    alt: 'Quadrant diagram “Feature-Priorisierung” with the quadrants strategic bets, quick wins, evaluate and backlog, each holding one feature.',
    size: landscape,
  },
  {
    slug: 'diagram-roadmap',
    title: 'Diagram: roadmap',
    file: 'examples/diagram-roadmap/diagram.json',
    tags: ['diagram', 'roadmap'],
    description: 'Three streams across four quarters, items connected within their stream.',
    alt: 'Roadmap diagram “Roadmap 2026” with quarters Q1 to Q4 and the streams platform, growth and operations, two connected items per stream.',
    size: landscape,
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
