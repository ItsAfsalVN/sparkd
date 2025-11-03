class StaticSkillDataSource {
  static const Map<String, List<String>> _rawSkillData = {
    // 1. Graphics & Design
    'graphics_design': [
      'Adobe Photoshop',
      'Adobe Illustrator',
      'Adobe InDesign',
      'Acrobat Pro',
      'Figma',
      'Sketch',
      'Adobe XD',
      'Canva',
      'Crello',
      'Blender',
      'After Effects',
    ],
    // 2. Digital Marketing
    'digital_marketing': [
      'Buffer',
      'Hootsuite',
      'Sprout Social',
      'Google Analytics',
      'Google Search Console',
      'SEMrush',
      'Ahrefs',
      'Moz',
      'Meta Ads Manager',
      'Google Ads',
      'LinkedIn Ads',
      'Google Business Profile',
    ],
    // 3. Video & Animation
    'video_animation': [
      'Adobe Premiere Pro',
      'Final Cut Pro',
      'DaVinci Resolve',
      'CapCut',
      'InShot',
      'VN Video Editor',
      'After Effects',
      'Moho',
      'Toon Boom Harmony',
      'OBS Studio',
      'Loom',
    ],
    // 4. Content & Writing
    'content_writing': [
      'Grammarly',
      'ProWritingAid',
      'SurferSEO',
      'Clearscope',
      'WordPress CMS',
      'Webflow CMS',
      'Ghost CMS',
      'DeepL',
      'Google Translate',
    ],
    // 5. Web & App Basics
    'web_app_basics': [
      'WordPress',
      'Shopify',
      'Wix',
      'Squarespace',
      'Webflow',
      'WooCommerce',
      'PrestaShop',
      'HTML5',
      'CSS3',
      'JavaScript',
      'Figma Prototyping',
      'Adobe XD Prototyping',
    ],
    // 6. Music & Audio
    'music_audio': [
      'Audacity',
      'Adobe Audition',
      'Logic Pro X',
      'Pro Tools',
      'Izotope Ozone',
      'Waves Plugins',
      'Rode Connect',
      'Focusrite Scarlett',
    ],
    // 7. Data & Admin Support
    'data_admin_support': [
      'Microsoft Excel',
      'Google Sheets',
      'LibreOffice Calc',
      'HubSpot CRM',
      'Zoho CRM',
      'Salesforce',
      'Trello',
      'Asana',
      'Monday.com',
      'Jira',
      'Rev',
      'Otter.ai',
    ],
    // 8. Photography
    'photography': [
      'Adobe Lightroom',
      'Capture One',
      'Adobe Photoshop',
      'Google Photos Management',
      'Dropbox File Management',
      'External Drive Organization',
      'DSLR Cameras',
      'Lighting Equipment',
    ],
    // 9. IT & Tech Support
    'it_tech_support': [
      'Google Workspace',
      'Microsoft 365',
      'Dropbox Cloud',
      'ExpressVPN',
      'LastPass',
      'Windows Diagnostics',
      'macOS Diagnostics',
    ],
    // 10. AI & Automation
    'ai_automation': [
      'ChatGPT',
      'Midjourney',
      'DALL-E',
      'Google Gemini',
      'Zapier',
      'IFTTT',
      'Intercom Chatbot',
      'Tidio Chatbot',
      'Jasper',
      'Copy.ai',
    ],
  };

  List<Map<String, dynamic>> getCategoriesWithTools() {
    return _rawSkillData.entries.map((entry) {
      final String categoryID = entry.key;
      final List<String> toolNames = entry.value;

      final String categoryName = categoryID
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');

      return {
        'categoryId': categoryID,
        'categoryName': categoryName,
        'tools': toolNames.map((toolName) {
          final String toolID = toolName.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '_',
          );
          return {'id': toolID, 'name': toolName};
        }).toList(),
      };
    }).toList();
  }
}
