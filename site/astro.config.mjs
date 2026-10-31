// @ts-check
import casoonPages from '@casoon/pages-theme';
import { defineConfig } from 'astro/config';
import { fileURLToPath } from 'node:url';

// Project-owned styles for notices in the docs; the vendored theme stays untouched.
const noticeStyles = {
  name: 'notice-styles',
  hooks: {
    'astro:config:setup': ({ injectScript }) => {
      injectScript('page-ssr', `import ${JSON.stringify(fileURLToPath(new URL('./src/notice.css', import.meta.url)))};`);
    },
  },
};

// Project page: https://casoon.github.io/typst-business-templates/ — `base` is the GitHub Pages path.
export default defineConfig({
  site: 'https://casoon.github.io/typst-business-templates',
  base: '/typst-business-templates/',
  integrations: [
    noticeStyles,
    casoonPages({
      name: 'typst-business-templates',
      description:
        'Generate standardized business PDFs from JSON data and reusable Typst templates, with fixed build inputs for reproducible output.',
      tagline: 'Deterministic documents with Typst',
      repo: 'casoon/typst-business-templates',
      version: '0.2.0',
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
