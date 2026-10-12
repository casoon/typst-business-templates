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
        'A Typst package with templates for invoices, offers, credentials, concepts and more, compiled to PDF and ZUGFeRD e-invoices by typstgen.',
      repo: 'casoon/typst-business-templates',
      version: '0.1.0',
      license: 'MIT',
      packages: [
        { label: 'typstgen', href: 'https://github.com/casoon/typstgen' },
        { label: 'chartlet', href: 'https://github.com/casoon/chartlet' },
      ],
      docsGroups: {
        'getting-started': 'Getting started',
        guides: 'Guides',
        reference: 'Reference',
      },
    }),
  ],
});
