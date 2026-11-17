import Overview from './components/Overview.astro';
import Sample from './components/Sample.astro';

// Components for docs/ MDX, which cannot import anything itself.
export const components = { Overview, Sample };
