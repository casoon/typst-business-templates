import { docsSchema } from '@casoon/pages-theme/content';
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';

// Sources: ../docs (docs/ in the project repository). The upper-case files at the top of docs/
// (PROJECT.md, ROADMAP.md …) are internal planning notes linked from the README, not site pages.
export const collections = {
  docs: defineCollection({
    loader: glob({ pattern: ['index.md', '*/**/*.{md,mdx}'], base: '../docs' }),
    schema: docsSchema,
  }),
};
