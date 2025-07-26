# OmnibusConverter Support Website

This is a static support website for the OmnibusConverter app hosted on Netlify to satisfy Apple's App Store requirements for a support URL.

## Features

- ✅ Professional design with app branding
- ✅ Contact form for user support requests
- ✅ FAQ section with common questions
- ✅ App information and features showcase
- ✅ Mobile-responsive design
- ✅ Form submission handling (via Netlify Forms)

## Setup Instructions

### 1. Form Submission Setup

The contact form uses **Netlify Forms** for email delivery. This is the recommended solution as it's fast, reliable, and free.

#### Netlify Forms Setup (Recommended)
1. **Deploy to Netlify**: Drag & drop the `support_website` folder to [netlify.com](https://netlify.com)
2. **Forms work automatically**: No additional setup needed!
3. **Free tier**: 100 form submissions per month
4. **Set up email notifications**:
   - Go to your Netlify dashboard
   - Click on your site
   - Go to "Forms" tab
   - Click "Form notifications"
   - Add "Email notification" with your email address

#### Alternative: Web3Forms (If you prefer)
1. Go to [Web3Forms.com](https://web3forms.com)
2. Get a free access key
3. Replace `YOUR-WEB3FORMS-KEY` in `web3forms-alternative.html`
4. Use `web3forms-alternative.html` instead of `index.html`

#### Alternative: AWS SES (For advanced users)
- Cost: ~$0.01/month for 100 emails
- Requires AWS setup (see AWS SES documentation)

### 2. Netlify Hosting Setup

#### Option A: Automated Deployment (Recommended)
1. **Using the deployment script** (from project root):
   ```bash
   ./deploy-netlify.sh
   ```

2. **Using npm scripts** (from support_website directory):
   ```bash
   npm run deploy
   # or
   npm run deploy:netlify
   ```

3. **Using Netlify CLI directly** (from support_website directory):
   ```bash
   netlify deploy --prod --dir=.
   ```

#### Option B: Manual Deployment
1. **Deploy to Netlify**:
   - Go to [netlify.com](https://netlify.com)
   - Drag & drop the `support_website` folder
   - Your site will be live instantly

#### Option C: GitHub Actions (Automatic)
1. **Set up GitHub secrets**:
   - `NETLIFY_AUTH_TOKEN`: Get from Netlify dashboard
   - `NETLIFY_SITE_ID`: Your site ID from Netlify
2. **Push to main branch**: Automatic deployment on changes

**Current Live URL**: `https://omnibus-converter.netlify.app`

### 3. Custom Domain (Optional)

For a professional look, you can set up a custom domain:

1. **In Netlify dashboard**: Go to "Domain management"
2. **Add custom domain**: Enter your domain (e.g., `support.omnibusconverter.com`)
3. **Update DNS**: Point your domain to Netlify's nameservers
4. **SSL certificate**: Automatically provided by Netlify

## File Structure

```
support_website/
├── index.html          # Main support page
├── privacy.html        # Privacy policy page
├── styles.css          # CSS styles
├── script.js           # JavaScript functionality
├── app-icon.png        # App icon (1024x1024)
├── web3forms-alternative.html  # Alternative form implementation
├── package.json        # NPM scripts and dependencies
├── .github/workflows/deploy.yml  # GitHub Actions workflow
└── README.md           # This file

deploy-netlify.sh       # Automated deployment script (project root)
```

## Customization

### Colors
The website uses a purple gradient theme. To change colors, edit the CSS variables in `styles.css`:

```css
/* Main gradient colors */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Content
- Update the FAQ section in `index.html` with your app-specific questions
- Modify the features section to match your app's capabilities
- Update the app description and tagline

### Logo
Replace `app-icon.png` with your app's icon (recommended size: 1024x1024px)

## Testing

1. **Local testing**: Open `index.html` in a web browser
2. **Live testing**: Visit your deployed URL (e.g., `https://omnibus-converter.netlify.app`)
3. **Form testing**: Submit a test message and check email notifications
4. **Mobile testing**: Test responsive design on different screen sizes
5. **Netlify dashboard**: Check "Forms" tab to see submissions

## App Store Integration

Update your App Store Connect support URL to:

**Current live URL:** `https://omnibus-converter.netlify.app`

**Privacy Policy URL:** `https://omnibus-converter.netlify.app/privacy.html`

## Support

If you need help setting up the website or have questions about the implementation, please refer to the AWS S3 documentation or contact the development team.

## License

This support website is created specifically for OmnibusConverter and follows the same licensing terms as the main application. # Test trigger
