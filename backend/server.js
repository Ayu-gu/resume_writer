const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const Anthropic = require('@anthropic-ai/sdk');

dotenv.config();

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Simple test route
app.get('/', (req, res) => {
  res.json({
    message: 'ResumeWriter backend is running!',
  });
});

// Temporary debug route: list Claude models available to this API key
app.get('/models', async (req, res) => {
  try {
    const models = await anthropic.models.list({
      limit: 100,
    });

    res.json({
      success: true,
      models: models.data.map((model) => model.id),
    });
  } catch (error) {
    console.error('Claude Models API error:', error);

    res.status(error.status || 500).json({
      success: false,
      error: error.message || 'Failed to list available Claude models.',
    });
  }
});

// Claude job analysis route

app.post('/analyse-job', async (req, res) => {

    try {
  
      const { jobDescription } = req.body;
  
      if (!jobDescription || !jobDescription.trim()) {
  
        return res.status(400).json({
  
          success: false,
  
          error: 'Job description is required.',
  
        });
  
      }
  
      const message = await anthropic.messages.create({
  
        model: 'claude-sonnet-5',
  
        max_tokens: 1500,
  
        messages: [
  
          {
  
            role: 'user',
  
            content: `
  
  Analyse the following job description for a resume tailoring application.
  
  Return ONLY valid JSON.
  
  Do not include markdown.
  
  Do not include backticks.
  
  Do not include any text before or after the JSON.
  
  Use exactly this structure:
  
  {
  
    "jobTitle": "string",
  
    "companyName": "string or Unknown",
  
    "summary": "short summary of what the employer is looking for",
  
    "requiredSkills": ["skill 1", "skill 2"],
  
    "preferredSkills": ["skill 1", "skill 2"],
  
    "keywords": ["keyword 1", "keyword 2"],
  
    "responsibilities": ["responsibility 1", "responsibility 2"],
  
    "qualifications": ["qualification 1", "qualification 2"],
  
    "experienceRequirements": ["requirement 1", "requirement 2"]
  
  }
  
  If information is not available, return an empty array or "Unknown".
  
  Job description:
  
  ${jobDescription}
  
            `,
  
          },
  
        ],
  
      });
  
      let rawAnalysis = message.content

  .filter((block) => block.type === 'text')

  .map((block) => block.text)

  .join('')

  .trim();

// Remove Markdown code fences if Claude adds them

rawAnalysis = rawAnalysis

  .replace(/^```json\s*/i, '')

  .replace(/^```\s*/, '')

  .replace(/\s*```$/, '')

  .trim();

let analysis;

try {

  analysis = JSON.parse(rawAnalysis);

} catch (parseError) {
  
        console.error('Failed to parse Claude JSON:', rawAnalysis);
  
        return res.status(500).json({
  
          success: false,
  
          error: 'Claude returned an invalid JSON response.',
  
          rawResponse: rawAnalysis,
  
        });
  
      }
  
      res.json({
  
        success: true,
  
        analysis,
  
      });
  
    } catch (error) {
  
      console.error('Claude API error:', error);
  
      res.status(error.status || 500).json({
  
        success: false,
  
        error: error.message || 'Failed to analyse the job description.',
  
      });
  
    }
  
  });

app.listen(PORT, () => {
  console.log(`ResumeWriter backend running on port ${PORT}`);
});