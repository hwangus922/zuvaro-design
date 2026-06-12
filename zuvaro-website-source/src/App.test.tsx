import { render, screen } from '@testing-library/react';
import App from './App';

describe('landing page smoke tests', () => {
  it('renders install buttons and legal links', () => {
    render(<App />);

    expect(screen.getAllByText('Install App').length).toBeGreaterThan(0);
    expect(screen.getByRole('link', { name: 'Privacy' }).getAttribute('href')).toContain('privacy.html');
    expect(screen.getByRole('link', { name: 'Terms' }).getAttribute('href')).toContain('terms.html');
  });
});
