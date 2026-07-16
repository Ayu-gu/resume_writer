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

// Debug route: list Claude models available to this API key
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

// Analyse job and compare against Solid Pod profile
app.post('/analyse-job', async (req, res) => {
  try {
    const { jobDescription, careerProfile } = req.body;

    if (
      !jobDescription ||
      typeof jobDescription !== 'string' ||
      !jobDescription.trim()
    ) {
      return res.status(400).json({
        success: false,
        error: 'Job description is required.',
      });
    }

    if (!careerProfile || typeof careerProfile !== 'object') {
      return res.status(400).json({
        success: false,
        error: 'Career profile from Solid Pod is required.',
      });
    }

    console.log('===== CAREER PROFILE RECEIVED FROM SOLID POD =====');
    console.log(careerProfile);
    console.log('==================================================');

    const message = await anthropic.messages.create({
      model: 'claude-sonnet-5',
      max_tokens: 2200,
      messages: [
        {
          role: 'user',
          content: `
You are analysing a job description and comparing it with a candidate's verified career profile stored in their Solid Pod.

Return ONLY valid JSON.
Do not include markdown.
Do not include backticks.
Do not include any text before or after the JSON.

Use exactly this JSON structure:

{
  "jobTitle": "string",
  "companyName": "string or Unknown",
  "summary": "short summary of what the employer is looking for",
  "requiredSkills": ["skill 1", "skill 2"],
  "preferredSkills": ["skill 1", "skill 2"],
  "keywords": ["keyword 1", "keyword 2"],
  "responsibilities": ["responsibility 1", "responsibility 2"],
  "qualifications": ["qualification 1", "qualification 2"],
  "experienceRequirements": ["requirement 1", "requirement 2"],
  "matchScore": 0,
  "matchedSkills": ["matched skill 1", "matched skill 2"],
  "missingSkills": ["missing skill 1", "missing skill 2"],
  "matchingExperience": ["relevant experience 1", "relevant experience 2"],
  "resumeRecommendations": ["recommendation 1", "recommendation 2"]
}

Rules:

1. matchScore must be an integer from 0 to 100.
2. Only identify a skill as matched if it is supported by the career profile.
3. Do not invent experience, education, qualifications, certifications or skills.
4. Treat empty career profile fields as unavailable information.
5. missingSkills should contain important job requirements not supported by the profile.
6. matchingExperience should identify which actual experience is relevant.
7. resumeRecommendations should explain what verified information should be emphasised.
8. If information is unavailable, use an empty array or "Unknown".

CANDIDATE CAREER PROFILE FROM SOLID POD:

${JSON.stringify(careerProfile, null, 2)}

JOB DESCRIPTION:

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

    rawAnalysis = rawAnalysis
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/, '')
      .replace(/\s*```$/, '')
      .trim();

    let analysis;

    try {
      analysis = JSON.parse(rawAnalysis);
    } catch (parseError) {
      console.error('Failed to parse Claude JSON.');
      console.error(rawAnalysis);

      return res.status(500).json({
        success: false,
        error: 'Claude returned an invalid JSON response.',
        rawResponse: rawAnalysis,
      });
    }

    console.log('===== JOB ANALYSIS COMPLETE =====');
    console.log(analysis);
    console.log('=================================');

    return res.json({
      success: true,
      analysis,
    });
  } catch (error) {
    console.error('Claude API error:', error);

    return res.status(error.status || 500).json({
      success: false,
      error:
        error.message ||
        'Failed to analyse the job description and career profile.',
    });
  }
});

// Generate structured tailored resume using verified Solid Pod data
app.post('/generate-resume', async (req, res) => {
  try {
    const { careerProfile, jobAnalysis } = req.body;

    if (!careerProfile || typeof careerProfile !== 'object') {
      return res.status(400).json({
        success: false,
        error: 'Career profile from Solid Pod is required.',
      });
    }

    if (!jobAnalysis || typeof jobAnalysis !== 'object') {
      return res.status(400).json({
        success: false,
        error: 'Job analysis is required.',
      });
    }

    console.log('===== GENERATING STRUCTURED TAILORED RESUME =====');
    console.log('Career profile:', careerProfile);
    console.log('Job analysis:', jobAnalysis);
    console.log('=================================================');

    const message = await anthropic.messages.create({
      model: 'claude-sonnet-5',
      max_tokens: 3200,
      messages: [
        {
          role: 'user',
          content: `
You are creating a professional, ATS-friendly tailored resume using only verified information from the candidate's Solid Pod career profile.

You MUST NOT invent:
- employers
- job titles
- dates
- qualifications
- certifications
- skills
- achievements
- responsibilities
- projects
- technologies

You may rewrite verified information to improve clarity, professionalism and relevance to the target role.

Return ONLY valid JSON.
Do not include markdown.
Do not include backticks.
Do not include any text before or after the JSON.

Use exactly this JSON structure:

{
  "fullName": "string",
  "email": "string",
  "phone": "string",
  "targetRole": "string",
  "professionalSummary": "string",

  "skills": [
    "skill 1",
    "skill 2"
  ],

  "experience": [
    {
      "role": "string",
      "company": "string",
      "dates": "string",
      "highlights": [
        "achievement or responsibility 1",
        "achievement or responsibility 2"
      ]
    }
  ],

  "projects": [
    {
      "title": "string",
      "description": "string",
      "highlights": [
        "project contribution 1",
        "project contribution 2"
      ]
    }
  ],

  "education": [
    {
      "qualification": "string",
      "institution": "string",
      "location": "string",
      "dates": "string"
    }
  ]
}

Rules:

1. fullName, email and phone must come directly from the career profile.

2. targetRole must come from the job analysis.

3. professionalSummary should be tailored to the target role using only verified career information.

4. skills must contain only skills explicitly supported by the candidate's career profile.

5. Prioritise skills relevant to the target job.

6. For experience:
   - Create separate entries only when the career profile clearly identifies separate employers, roles or experiences.
   - Do not invent job titles or dates.
   - If an exact job title is not available, use a conservative verified description such as "Customer Service and Leadership Experience".
   - If dates are unavailable, use an empty string.
   - Do not create achievements that are not supported by the profile.

7. For projects:
   - Include genuine projects mentioned in the profile.
   - Do not invent project names or technologies.
   - Emphasise verified technical, leadership and stakeholder contributions.

8. For education:
   - Use only education information clearly contained in the career profile.
   - If an institution, location or dates cannot be confidently separated, keep unavailable fields as empty strings.

9. Do not include missing job requirements as if the candidate possesses them.

10. Keep the content concise, ATS-friendly and suitable for a real job application.

VERIFIED CAREER PROFILE FROM SOLID POD:

${JSON.stringify(careerProfile, null, 2)}

JOB ANALYSIS:

${JSON.stringify(jobAnalysis, null, 2)}
          `,
        },
      ],
    });

    let rawResume = message.content
      .filter((block) => block.type === 'text')
      .map((block) => block.text)
      .join('')
      .trim();

    rawResume = rawResume
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/, '')
      .replace(/\s*```$/, '')
      .trim();

    let resume;

    try {
      resume = JSON.parse(rawResume);
    } catch (parseError) {
      console.error('Failed to parse generated resume JSON.');
      console.error(rawResume);

      return res.status(500).json({
        success: false,
        error: 'Claude returned an invalid resume JSON response.',
        rawResponse: rawResume,
      });
    }

    console.log('===== STRUCTURED TAILORED RESUME GENERATED =====');
    console.log(JSON.stringify(resume, null, 2));
    console.log('================================================');

    return res.json({
      success: true,
      resume,
    });
  } catch (error) {
    console.error('Claude resume generation error:', error);

    return res.status(error.status || 500).json({
      success: false,
      error:
        error.message ||
        'Failed to generate the tailored resume.',
    });
  }
});

// Start backend server
app.listen(PORT, () => {
  console.log(`ResumeWriter backend running on port ${PORT}`);
});