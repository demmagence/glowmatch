import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { ingredients } = await req.json()
    if (!ingredients || !Array.isArray(ingredients)) {
      return new Response(
        JSON.stringify({ error: 'Ingredients array is required in the body' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({ error: 'GEMINI_API_KEY is not configured in Edge Function environment variables' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      )
    }

    // Build the structured prompt for Gemini
    const prompt = `
You are a skincare ingredients safety analyzer.
Analyze the following ingredients: ${JSON.stringify(ingredients)}.

For each ingredient, classify its safety level as exactly one of: "Safe", "Caution", or "Avoid".
Evaluate safety based on skin irritation, pore-clogging potential (comedogenicity), allergenicity, and toxicity.
Provide a short explanation (1-2 sentences) of why that ingredient was classified this way.

Also, detect any potential interaction warnings or bad combinations between these ingredients. Specifically note interactions between:
- BHA (Salicylic Acid) + Retinol
- Vitamin C + AHA/BHA
- Niacinamide + Vitamin C
- Retinol + AHA/BHA
- Or any other harsh combination.

Finally, calculate an overall safety score from 0 to 100 based on the proportion and severity of "Caution" and "Avoid" ingredients. (100 if all Safe, lower if there are Avoids or Cautions).

Return a JSON object in this exact schema (no markdown, no backticks, just raw JSON):
{
  "detectedIngredients": ["ingredient1", "ingredient2"],
  "ingredientSafetyLevels": {
    "ingredient1": "Safe",
    "ingredient2": "Caution"
  },
  "ingredientDetails": {
    "ingredient1": "Explanation for safety level of ingredient1.",
    "ingredient2": "Explanation for safety level of ingredient2."
  },
  "overallSafetyScore": 85,
  "safetyRating": "Highly Safe (100% Clean)",
  "skinTypeSuitability": "Excellent for oily skin, caution for dry skin due to drying agents.",
  "interactionWarnings": ["Avoid combining Salicylic Acid and Retinol in the same routine step."],
  "recommendations": "Use sunscreen daily if this product contains Retinol or AHA.",
  "isSafe": true
}
`;

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [{ text: prompt }]
          }],
          generationConfig: {
            responseMimeType: "application/json"
          }
        })
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      return new Response(
        JSON.stringify({ error: `Gemini API call failed: ${errorText}` }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: response.status }
      )
    }

    const responseData = await response.json()
    const responseText = responseData.candidates[0].content.parts[0].text

    // Try parsing to verify it is valid JSON
    const parsedData = JSON.parse(responseText.trim())

    return new Response(
      JSON.stringify(parsedData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
