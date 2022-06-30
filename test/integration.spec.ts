import { test, expect } from '@playwright/test';

test('should navigate to the react page', async ({ page }) => {
  // Start from the index page (the baseURL is set via the webServer in the playwright.config.ts)
  await page.goto('/');
  const title = page.locator('h1');
  await expect(title).toHaveText('Ethereum node deployment templates');
});
