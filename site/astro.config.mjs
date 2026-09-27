// @ts-check
import casoonPages from '@casoon/pages-theme';
import { defineConfig } from 'astro/config';

// Project page: https://casoon.github.io/typst-business-templates/ — `base` is the GitHub Pages path.
export default defineConfig({
  site: 'https://casoon.github.io/typst-business-templates',
  base: '/typst-business-templates/',
  integrations: [
    casoonPages({
      name: 'typst-business-templates',
      description:
        'Typst templates for invoices, offers, credentials, concepts and more, compiled to PDF from JSON by the docgen CLI or the Rust library.',
      repo: 'casoon/typst-business-templates',
      version: '0.7.2',
      license: 'MIT',
      packages: [
        { label: 'GitHub releases', href: 'https://github.com/casoon/typst-business-templates/releases' },
        { label: 'crates.io', href: 'https://crates.io/crates/typst-business-templates' },
        { label: 'docs.rs', href: 'https://docs.rs/typst-business-templates' },
        { label: 'Product page', href: 'https://typst-business-templates.casoon.de' },
      ],
      docsGroups: {
        'getting-started': 'Getting started',
        guides: 'Guides',
        reference: 'Reference',
      },
    }),
  ],
});
