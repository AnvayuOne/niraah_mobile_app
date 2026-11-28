// SAMPLE DATA, copied from niraah-platform/design/sample/*.json.
// Imported only through lib/main_sample.dart; never from lib/main.dart
// (constitution §2 rule 6). Not clinically reviewed.

/// Client version document for the onboarding questionnaire.
const String sampleQuestionnaireJson = r'''
{
  "$sample": "SAMPLE DATA for UI building only (constitution §2 rule 6). Not clinically reviewed. Shape follows the client version document in spec 005 'API behaviour for clients': no weights, maximums, boundaries or flags.",
  "questionnaireKey": "onboarding",
  "versionNumber": 1,
  "purpose": "onboarding",
  "estimatedMinutes": 3,
  "questions": [
    {
      "key": "date_of_birth",
      "type": "date",
      "required": true,
      "text": "When were you born?",
      "helpText": "Niraah is for adults. Your age helps us personalise your care.",
      "illustration": "q01_age",
      "motion": "float"
    },
    {
      "key": "cycle_regularity",
      "type": "single_choice",
      "required": true,
      "text": "How regular is your cycle?",
      "helpText": "Think about the last six months.",
      "illustration": "q02_cycle",
      "motion": "breathe",
      "options": [
        { "value": "regular", "label": "Like clockwork, every 21 to 35 days", "color": "mint" },
        { "value": "sometimes_off", "label": "Sometimes early or late", "color": "apricot" },
        { "value": "irregular", "label": "Often irregular", "color": "peach" },
        { "value": "rare", "label": "I rarely get a period", "color": "blush" },
        { "value": "pregnant", "label": "I'm pregnant", "color": "lavender" }
      ]
    },
    {
      "key": "last_period",
      "type": "single_choice",
      "required": true,
      "text": "How long since your last period?",
      "illustration": "q02_cycle",
      "motion": "breathe",
      "displayCondition": { "match": "all", "rules": [{ "question": "cycle_regularity", "operator": "is", "values": ["rare"] }] },
      "options": [
        { "value": "under_3_months", "label": "Less than three months", "color": "apricot" },
        { "value": "over_3_months", "label": "Three months or more", "color": "blush" }
      ]
    },
    {
      "key": "mood",
      "type": "single_choice",
      "required": true,
      "text": "How have you been feeling most days?",
      "illustration": "q03_mood",
      "motion": "sway",
      "options": [
        { "value": "energetic", "label": "Energetic", "color": "mint", "icon": "screen02_mood_energetic" },
        { "value": "anxious", "label": "Anxious", "color": "lavender", "icon": "screen02_mood_anxious" },
        { "value": "tired", "label": "Tired", "color": "peach", "icon": "screen02_mood_fatigue" },
        { "value": "hormonal", "label": "Up and down", "color": "blush", "icon": "screen02_mood_hormonal" }
      ]
    },
    {
      "key": "symptoms",
      "type": "multiple_choice",
      "required": true,
      "text": "Have you noticed any of these lately?",
      "helpText": "Choose all that apply.",
      "illustration": "q04_symptoms",
      "motion": "float",
      "options": [
        { "value": "acne", "label": "Acne or oily skin", "color": "peach" },
        { "value": "hair_growth", "label": "Extra hair growth", "color": "apricot" },
        { "value": "hair_thinning", "label": "Hair thinning", "color": "lavender" },
        { "value": "weight_change", "label": "Weight changes", "color": "sage" },
        { "value": "heavy_bleeding", "label": "Very heavy bleeding", "color": "blush" },
        { "value": "pelvic_pain", "label": "Severe pelvic pain", "color": "blush" },
        { "value": "none", "label": "None of these", "color": "mint", "exclusive": true }
      ]
    },
    {
      "key": "diet",
      "type": "single_choice",
      "required": true,
      "text": "What does a usual day of eating look like?",
      "illustration": "q05_diet",
      "motion": "float",
      "options": [
        { "value": "balanced", "label": "Home-cooked and balanced", "color": "mint" },
        { "value": "mostly_home", "label": "Mostly home food, some snacking", "color": "apricot" },
        { "value": "rushed", "label": "Often rushed or skipped meals", "color": "peach" },
        { "value": "outside", "label": "Mostly food from outside", "color": "blush" }
      ]
    },
    {
      "key": "activity",
      "type": "scale",
      "required": true,
      "text": "How active are you in a typical week?",
      "illustration": "q06_activity",
      "motion": "sway",
      "steps": [
        { "value": "1", "label": "Rarely" },
        { "value": "2", "label": "A little" },
        { "value": "3", "label": "Sometimes" },
        { "value": "4", "label": "Often" },
        { "value": "5", "label": "Most days" }
      ]
    },
    {
      "key": "stress",
      "type": "scale",
      "required": true,
      "text": "How heavy has stress felt lately?",
      "illustration": "q07_stress",
      "motion": "breathe",
      "steps": [
        { "value": "1", "label": "Light" },
        { "value": "2", "label": "Manageable" },
        { "value": "3", "label": "Noticeable" },
        { "value": "4", "label": "Heavy" },
        { "value": "5", "label": "Overwhelming" }
      ]
    },
    {
      "key": "sleep",
      "type": "single_choice",
      "required": true,
      "text": "How do you usually sleep?",
      "illustration": "q08_sleep",
      "motion": "breathe",
      "options": [
        { "value": "rested", "label": "I wake up rested most days", "color": "mint" },
        { "value": "light", "label": "Okay, but light", "color": "apricot" },
        { "value": "tired", "label": "I often wake up tired", "color": "peach" },
        { "value": "hard", "label": "It's hard to fall or stay asleep", "color": "lavender" }
      ]
    },
    {
      "key": "goal",
      "type": "single_choice",
      "required": true,
      "text": "What would you most like help with?",
      "illustration": "q09_goal",
      "motion": "float",
      "options": [
        { "value": "understand_cycle", "label": "Understanding my cycle", "color": "blush" },
        { "value": "pcos", "label": "Managing PCOS", "color": "peach" },
        { "value": "conceive", "label": "Planning a pregnancy", "color": "lavender" },
        { "value": "energy_weight", "label": "Energy and weight", "color": "mint" },
        { "value": "calm", "label": "Feeling calmer", "color": "sage" }
      ]
    },
    {
      "key": "notes",
      "type": "short_text",
      "required": false,
      "text": "Anything else you'd like us to know?",
      "helpText": "Optional. Please don't include your name or contact details.",
      "illustration": "q10_support",
      "motion": "float",
      "maxLength": 200
    }
  ]
}
''';

/// Server-only scoring rules. Never sent to a client.
const String sampleScoringJson = r'''
{
  "$sample": "SAMPLE DATA for UI building only. Server-side scoring rules (spec 005); never sent to clients. Weights, bands and flag severities are placeholders and are NOT clinically reviewed.",
  "totalMaximum": 100,
  "dimensions": [
    { "key": "cycle", "name": "Cycle", "maximum": 10, "share": 30 },
    { "key": "metabolic", "name": "Metabolic", "maximum": 30, "share": 30 },
    { "key": "mind", "name": "Mind", "maximum": 20, "share": 20 },
    { "key": "rest", "name": "Rest", "maximum": 10, "share": 20 }
  ],
  "levels": [
    { "from": 70, "label": "Strong" },
    { "from": 40, "label": "Steady" },
    { "from": 0, "label": "Needs care" }
  ],
  "weights": {
    "cycle_regularity": { "regular": { "cycle": 10 }, "sometimes_off": { "cycle": 7 }, "irregular": { "cycle": 3 }, "rare": { "cycle": 0 }, "pregnant": { "cycle": 8 } },
    "last_period": { "under_3_months": { "cycle": 0 }, "over_3_months": { "cycle": 0 } },
    "mood": { "energetic": { "mind": 10 }, "anxious": { "mind": 4 }, "tired": { "mind": 5 }, "hormonal": { "mind": 4 } },
    "symptoms": { "none": { "metabolic": 10 } },
    "diet": { "balanced": { "metabolic": 10 }, "mostly_home": { "metabolic": 7 }, "rushed": { "metabolic": 3 }, "outside": { "metabolic": 2 } },
    "activity": { "1": { "metabolic": 0 }, "2": { "metabolic": 3 }, "3": { "metabolic": 6 }, "4": { "metabolic": 8 }, "5": { "metabolic": 10 } },
    "stress": { "1": { "mind": 10 }, "2": { "mind": 8 }, "3": { "mind": 5 }, "4": { "mind": 2 }, "5": { "mind": 0 } },
    "sleep": { "rested": { "rest": 10 }, "light": { "rest": 6 }, "tired": { "rest": 3 }, "hard": { "rest": 1 } }
  },
  "flagsRaised": {
    "cycle_regularity": { "pregnant": ["pregnant"] },
    "last_period": { "over_3_months": ["missed_periods_3_plus"] },
    "symptoms": { "heavy_bleeding": ["heavy_bleeding"], "pelvic_pain": ["severe_pelvic_pain"] },
    "goal": { "conceive": ["trying_to_conceive"] }
  },
  "flags": {
    "pregnant": { "severity": "attention", "fallbackObservation": "You told us you're pregnant. We'll keep your suggestions pregnancy-safe." },
    "missed_periods_3_plus": { "severity": "attention", "fallbackObservation": "It has been a while since your last period. That's worth mentioning to a doctor." },
    "heavy_bleeding": { "severity": "urgent", "careMessage": "Some of your answers suggest you should speak to a doctor soon.", "fallbackObservation": "Very heavy bleeding is something a doctor should look at." },
    "severe_pelvic_pain": { "severity": "urgent", "careMessage": "Some of your answers suggest you should speak to a doctor soon.", "fallbackObservation": "Severe pelvic pain is something a doctor should look at." },
    "trying_to_conceive": { "severity": "information", "fallbackObservation": "You're planning a pregnancy. We can guide you through each step." }
  },
  "bands": [
    { "min": 80, "max": 100, "label": "Thriving", "message": "Your habits are giving your body a lot of support.", "color": "mint", "fallbackObservation": "Your answers show steady routines you can build on." },
    { "min": 60, "max": 79, "label": "Optimizing", "message": "A strong base, with a few areas to fine-tune.", "color": "apricot", "fallbackObservation": "A few small changes could make your days feel easier." },
    { "min": 40, "max": 59, "label": "Building", "message": "You're building the foundations. We'll take it one step at a time.", "color": "peach", "fallbackObservation": "Some of your answers point to areas where gentle support could help." },
    { "min": 0, "max": 39, "label": "Needs care", "message": "Your body is asking for some extra care right now. You're not alone in this.", "color": "blush", "fallbackObservation": "Your answers suggest a doctor's view would be helpful." }
  ],
  "programRules": [
    { "program": "fertility", "name": "Fertility journey", "whenFlags": ["trying_to_conceive"] },
    { "program": "pcos", "name": "PCOS reset", "whenDimensionBelow": { "cycle": 50 } },
    { "program": "metabolic", "name": "Metabolic balance", "whenDimensionBelow": { "metabolic": 50 } }
  ]
}
''';

/// Public plans list.
const String samplePlansJson = r'''
{
  "$sample": "SAMPLE DATA for UI building only. Shape follows the public plans list in spec 004 'Public API behaviour'. Prices are the Design Story samples, including GST.",
  "trial": {
    "days": 7,
    "note": "The trial covers AI and self-guided features. Doctor and dietitian care starts with your first payment."
  },
  "plans": [
    {
      "id": "free",
      "name": "Free",
      "description": "AI Care, cycle tracking and self-guided support. Nothing you enter goes to a doctor on this plan.",
      "colorToken": "tier0",
      "highlighted": false,
      "isFree": true,
      "recommendedFor": { "bands": [], "flags": [] },
      "prices": [],
      "features": [
        { "key": "cycle_tracking.access", "name": "Cycle and symptom tracking", "value": true },
        { "key": "ai_chat.messages", "name": "AI Care chat", "value": { "limit": 10, "period": "day" } },
        { "key": "meal_scan.scans", "name": "Meal scans", "value": { "limit": 1, "period": "day" } },
        { "key": "yoga.library", "name": "Yoga and breathwork library", "value": true }
      ],
      "extraLines": []
    },
    {
      "id": "foundation",
      "name": "Foundation",
      "description": "Track, learn and get AI guidance every day.",
      "colorToken": "tier1",
      "highlighted": false,
      "recommendedFor": { "bands": ["Thriving", "Optimizing"], "flags": [] },
      "prices": [{ "id": "foundation-30d", "amountPaise": 49900, "currency": "INR", "validity": { "count": 30, "unit": "days" }, "renews": true }],
      "features": [
        { "key": "cycle_tracking.access", "name": "Cycle and symptom tracking", "value": true },
        { "key": "ai_chat.messages", "name": "AI Care chat", "value": { "limit": 30, "period": "day" } },
        { "key": "meal_scan.scans", "name": "Meal scans", "value": { "limit": 3, "period": "day" } },
        { "key": "yoga.library", "name": "Yoga and breathwork library", "value": true },
        { "key": "prescore.doctor_review", "name": "Doctor reviews your pre-score", "value": true }
      ],
      "extraLines": []
    },
    {
      "id": "essential",
      "name": "Essential",
      "description": "Doctor-reviewed care plan and monthly consults.",
      "colorToken": "tier2",
      "highlighted": true,
      "badge": "Most popular",
      "recommendedFor": { "bands": ["Building", "Needs care"], "flags": [] },
      "prices": [{ "id": "essential-30d", "amountPaise": 99900, "currency": "INR", "validity": { "count": 30, "unit": "days" }, "renews": true }],
      "features": [
        { "key": "cycle_tracking.access", "name": "Cycle and symptom tracking", "value": true },
        { "key": "ai_chat.messages", "name": "AI Care chat", "value": { "limit": 100, "period": "day" } },
        { "key": "meal_scan.scans", "name": "Meal scans", "value": { "limit": 10, "period": "day" } },
        { "key": "prescore.doctor_review", "name": "Doctor reviews your pre-score", "value": true },
        { "key": "care_plan.doctor_reviewed", "name": "Doctor-signed care plan", "value": true },
        { "key": "consults.doctor_included", "name": "Doctor consult", "value": { "quantity": 1, "period": "month" } },
        { "key": "programs.access", "name": "Guided programs", "value": true }
      ],
      "extraLines": []
    },
    {
      "id": "premium",
      "name": "Premium",
      "description": "A dedicated care team with your own doctor and dietitian.",
      "colorToken": "tier3",
      "highlighted": false,
      "recommendedFor": { "bands": [], "flags": ["heavy_bleeding", "severe_pelvic_pain"] },
      "prices": [{ "id": "premium-30d", "amountPaise": 199900, "currency": "INR", "validity": { "count": 30, "unit": "days" }, "renews": true }],
      "features": [
        { "key": "cycle_tracking.access", "name": "Cycle and symptom tracking", "value": true },
        { "key": "ai_chat.messages", "name": "AI Care chat", "value": { "unlimited": true } },
        { "key": "prescore.doctor_review", "name": "Doctor reviews your pre-score", "value": true },
        { "key": "care_team.dedicated_doctor", "name": "Your own doctor", "value": true },
        { "key": "care_team.dedicated_dietitian", "name": "Your own dietitian", "value": true },
        { "key": "consults.doctor_included", "name": "Doctor consults", "value": { "quantity": 2, "period": "month" } },
        { "key": "yoga.live_classes", "name": "Live yoga classes", "value": { "quantity": 4, "period": "month" } }
      ],
      "extraLines": ["Priority support"]
    }
  ]
}
''';

/// Daily suggestion library (spec 009 "Daily suggestion").
const String sampleDailyContentJson = r'''
{
  "$sample": "SAMPLE DATA for UI building only. Stands in for the clinician-approved content library behind the daily suggestion (spec 009 'Daily suggestion', spec 010 §2). NOT clinically reviewed. No medicines, diagnoses, calories or weight. Rules shortlist by phase ('any' fits every phase and the no-phase case); the item for a day is chosen by day of year so it is stable all day.",
  "items": [
    { "key": "menstrual_warmth", "phases": ["menstrual"], "title": "Gentle warmth", "text": "A warm drink and a slower evening can make the first days of your period feel easier." },
    { "key": "menstrual_rest", "phases": ["menstrual"], "title": "Rest counts", "text": "It's fine to choose a lighter day. A short, easy walk is enough movement for today." },
    { "key": "follicular_walk", "phases": ["follicular"], "title": "A brisk walk", "text": "Energy often rises in this part of the cycle. A 15-minute brisk walk after a meal is a good fit." },
    { "key": "follicular_plan", "phases": ["follicular"], "title": "Plan a home-cooked meal", "text": "Pick one meal this week to cook at home with dal, vegetables and a whole grain." },
    { "key": "ovulatory_social", "phases": ["ovulatory"], "title": "Make time for people", "text": "Many people feel more social around now. A call or walk with a friend can lift the day." },
    { "key": "luteal_sleep", "phases": ["luteal"], "title": "Protect your sleep", "text": "Try putting your phone away 30 minutes before bed for the next few nights." },
    { "key": "luteal_breath", "phases": ["luteal"], "title": "Two minutes of breathing", "text": "Slow breathing, in for four counts and out for six, can help on a tense afternoon." },
    { "key": "any_water", "phases": ["any"], "title": "A glass of water", "text": "Keep a glass of water where you can see it, and refill it when it's empty." },
    { "key": "any_log", "phases": ["any"], "title": "Notice how you feel", "text": "Logging your mood and energy for a few days helps you see your own patterns." },
    { "key": "any_stretch", "phases": ["any"], "title": "A short stretch", "text": "Five minutes of gentle stretching between tasks is a kind break for your body." }
  ]
}
''';

/// Symptom catalogue with red-flag rules (spec 010 §4).
const String sampleSymptomsJson = r'''
{
  "$sample": "SAMPLE stand-in for the `symptoms` catalogue (spec 002): key, name, category, red-flag rule. NOT clinically reviewed. A red-flag rule here shows the keyed advice from content-messages.json at once (spec 010 §4.4, AC17); `minSeverity` means the rule applies from that severity up.",
  "severityWords": { "low": "Mild", "high": "Very strong" },
  "categories": [
    { "key": "body", "name": "Body" },
    { "key": "skin_hair", "name": "Skin and hair" },
    { "key": "mind", "name": "Mind and mood" },
    { "key": "digestion", "name": "Digestion" },
    { "key": "cycle", "name": "Cycle" }
  ],
  "symptoms": [
    { "key": "cramps", "name": "Cramps", "category": "body" },
    { "key": "headache", "name": "Headache", "category": "body" },
    { "key": "back_pain", "name": "Back pain", "category": "body" },
    { "key": "breast_tenderness", "name": "Breast tenderness", "category": "body" },
    { "key": "fatigue", "name": "Tiredness", "category": "body" },
    { "key": "severe_pelvic_pain", "name": "Severe pelvic pain", "category": "body", "redFlag": { "message": "symptom.severe_pelvic_pain" } },
    { "key": "fainting", "name": "Fainting or feeling faint", "category": "body", "redFlag": { "message": "symptom.fainting" } },
    { "key": "acne", "name": "Acne", "category": "skin_hair" },
    { "key": "hair_growth", "name": "Extra hair growth", "category": "skin_hair" },
    { "key": "hair_thinning", "name": "Hair thinning", "category": "skin_hair" },
    { "key": "low_mood", "name": "Low mood", "category": "mind" },
    { "key": "anxiety", "name": "Anxiety", "category": "mind" },
    { "key": "irritability", "name": "Irritability", "category": "mind" },
    { "key": "poor_sleep", "name": "Poor sleep", "category": "mind" },
    { "key": "bloating", "name": "Bloating", "category": "digestion" },
    { "key": "cravings", "name": "Cravings", "category": "digestion" },
    { "key": "nausea", "name": "Nausea", "category": "digestion" },
    { "key": "spotting", "name": "Spotting between periods", "category": "cycle" },
    { "key": "very_heavy_bleeding", "name": "Very heavy bleeding", "category": "cycle", "redFlag": { "message": "symptom.very_heavy_bleeding", "minSeverity": 7 } }
  ]
}
''';

/// Clinician-keyed wording (spec 010 "Wellness-only wording" 4).
const String sampleContentMessagesJson = r'''
{
  "$sample": "SAMPLE stand-in for `content_messages` (spec 002, spec 010 'Wellness-only wording' 4): keyed wording written and approved by clinicians in the real product. NOT clinically reviewed; placeholders until clinicians supply the text.",
  "messages": {
    "advice.not_passed_on": "Niraah has not passed this on to a doctor. Please see a doctor yourself.",
    "cycle.no_period_90": {
      "title": "It's been a while since your last period",
      "text": "Going 90 days or more without a period is worth talking to a doctor about. Please book a visit with a doctor soon."
    },
    "cycle.long_bleeding": {
      "title": "You've logged bleeding for 10 days or more",
      "text": "Bleeding that goes on this long should be checked by a doctor. Please see a doctor soon."
    },
    "symptom.severe_pelvic_pain": {
      "title": "Please see a doctor soon",
      "text": "Severe pelvic pain should be checked by a doctor. If the pain is sudden and very strong, or you feel faint, seek urgent care now."
    },
    "symptom.very_heavy_bleeding": {
      "title": "Please see a doctor soon",
      "text": "Soaking through a pad or tampon every hour, or passing large clots, should be checked by a doctor. If you feel dizzy or faint, seek urgent care now."
    },
    "symptom.fainting": {
      "title": "Please seek care now",
      "text": "Fainting should be checked by a doctor straight away. If you are alone, call someone to be with you."
    },
    "wellness.cycle": "Niraah supports your wellbeing. It does not replace your own doctor.",
    "cycle.predictions_disclaimer": "Predictions are estimates. Do not use them to prevent or plan a pregnancy."
  }
}
''';

/// Fixed chat safety rules (spec 009 "Chat safety").
const String sampleChatSafetyJson = r'''
{
  "$sample": "SAMPLE stand-in for the fixed safety rules that screen every chat message before any model call (spec 009 'Chat safety'). Patterns are lower-case substrings matched against the masked message. The cards' wording is clinician content in the real product. NOT clinically reviewed. Helplines are the starting points the launch checklist names for clinicians to verify (OPEN-QUESTIONS.md); they must be verified before launch.",
  "order": ["self_harm", "emergency", "medicine", "diagnosis"],
  "rules": {
    "self_harm": {
      "patterns": ["kill myself", "end my life", "suicide", "suicidal", "hurt myself", "self harm", "self-harm", "don't want to live", "want to die"],
      "card": {
        "kind": "crisis",
        "title": "You don't have to go through this alone",
        "text": "It sounds like you're going through something really hard. Please reach out to someone now.",
        "actions": [
          { "label": "Call Tele-MANAS 14416 (free, 24 hours)", "href": "tel:14416" },
          { "label": "Emergency: call 112", "href": "tel:112" }
        ]
      },
      "alertWhenPlanIncludes": "care_team.urgent_alerts"
    },
    "emergency": {
      "patterns": ["chest pain", "fainted", "fainting", "can't breathe", "cannot breathe", "heavy bleeding and pregnant", "bleeding in pregnancy", "pregnant and bleeding", "severe bleeding"],
      "card": {
        "kind": "emergency",
        "title": "Please seek care now",
        "text": "What you describe needs urgent medical attention. Go to the nearest emergency department or call 112.",
        "actions": [{ "label": "Call 112", "href": "tel:112" }]
      },
      "alertWhenPlanIncludes": "care_team.urgent_alerts"
    },
    "medicine": {
      "patterns": ["dose", "dosage", "how many tablets", "should i stop taking", "stop my medicine", "increase my medicine", "metformin", "which pill", "what medicine", "which medicine", "contraceptive pill"],
      "card": {
        "kind": "medicine",
        "title": "Niraah AI can't advise on medicines",
        "text": "Questions about starting, stopping or changing a medicine or its dose need a doctor who knows your health.",
        "actions": [{ "label": "Book a doctor", "href": "/home" }]
      }
    },
    "diagnosis": {
      "patterns": ["do i have pcos", "do i have", "am i infertile", "diagnose me", "what's wrong with me", "what is wrong with me"],
      "note": "Not a card. The answer may give general, cited information and must say that only a clinician can diagnose."
    }
  },
  "diagnosisLine": "Only a clinician can diagnose a condition. I can share general information."
}
''';

/// Sample knowledge documents and canned answers (spec 009 "Knowledge and citations").
const String sampleChatKnowledgeJson = r'''
{
  "$sample": "SAMPLE stand-in for the approved knowledge documents and for the model that answers from them (spec 009 'Knowledge and citations'). There is no model in the sample: answers are canned sentences, each tied to the passage it relies on. The documents are deliberately labelled as sample documents so that no real publisher is credited with text it did not write. NOT clinically reviewed.",
  "footer": "AI insights do not replace medical advice.",
  "notADoctor": "AI Care is not a doctor. It shares general wellness information from sources our clinicians have approved.",
  "noSource": "I don't have reliable information on that. A doctor is the best person to ask.",
  "documents": [
    {
      "id": "doc-cycle",
      "title": "Understanding your menstrual cycle (sample document)",
      "publisher": "Niraah sample library",
      "passages": [
        { "id": "cycle-1", "text": "A menstrual cycle is counted from the first day of one period to the day before the next. Many cycles last between 21 and 35 days, and some variation from month to month is common." },
        { "id": "cycle-2", "text": "Energy and mood can change across the cycle. Some people notice more energy in the days after a period and feel more tired in the days before the next one." }
      ]
    },
    {
      "id": "doc-pcos",
      "title": "Living well with PCOS (sample document)",
      "publisher": "Niraah sample library",
      "passages": [
        { "id": "pcos-1", "text": "Polycystic ovary syndrome (PCOS) is a common hormonal condition. It is diagnosed by a doctor, usually from a combination of symptoms, examination and tests." },
        { "id": "pcos-2", "text": "Regular movement, balanced meals and good sleep are commonly recommended as part of managing PCOS, alongside any care a doctor advises." }
      ]
    },
    {
      "id": "doc-food",
      "title": "Everyday eating for hormonal health (sample document)",
      "publisher": "Niraah sample library",
      "passages": [
        { "id": "food-1", "text": "Meals built around vegetables, pulses such as dal, whole grains and a source of protein tend to release energy more steadily than meals based mostly on refined flour or sugar." },
        { "id": "food-2", "text": "Eating at regular times and not skipping meals can help keep energy more even through the day." }
      ]
    },
    {
      "id": "doc-sleep",
      "title": "Sleep and stress basics (sample document)",
      "publisher": "Niraah sample library",
      "passages": [
        { "id": "sleep-1", "text": "A regular bedtime, a dark and cool room, and putting screens away before bed are simple habits that support sleep." },
        { "id": "sleep-2", "text": "Slow breathing, such as breathing out for longer than you breathe in, is a simple way to help the body relax." }
      ]
    }
  ],
  "intents": [
    {
      "key": "greeting",
      "keywords": ["hello", "hi ", "hey", "good morning", "good evening", "thank"],
      "medical": false,
      "sentences": [{ "text": "Hello! I'm here to help with questions about your cycle, food, sleep and wellbeing." }]
    },
    {
      "key": "cycle_length",
      "keywords": ["cycle length", "how long is a cycle", "irregular", "late period", "period late", "normal cycle", "cycle normal"],
      "medical": true,
      "sentences": [
        { "text": "A cycle is counted from the first day of one period to the day before the next.", "cite": "cycle-1" },
        { "text": "Many cycles last between 21 and 35 days, and some variation from month to month is common.", "cite": "cycle-1" },
        { "text": "Your Cycle tab shows your own logged cycles, so you can see your usual range.", "personal": true }
      ]
    },
    {
      "key": "tired",
      "keywords": ["tired", "energy", "fatigue", "exhausted", "low energy"],
      "medical": true,
      "sentences": [
        { "text": "Energy can change across the cycle, and some people feel more tired in the days before a period.", "cite": "cycle-2" },
        { "text": "Eating at regular times and not skipping meals can help keep energy more even.", "cite": "food-2" },
        { "text": "You're in your {phase} right now, by our estimate, so it may help to note how your energy changes over the next few days.", "personal": true, "needsPhase": true }
      ]
    },
    {
      "key": "pcos_lifestyle",
      "keywords": ["pcos", "polycystic"],
      "medical": true,
      "sentences": [
        { "text": "PCOS is a common hormonal condition, and it is diagnosed by a doctor.", "cite": "pcos-1" },
        { "text": "Regular movement, balanced meals and good sleep are commonly recommended as part of managing it, alongside any care a doctor advises.", "cite": "pcos-2" }
      ]
    },
    {
      "key": "food",
      "keywords": ["eat", "food", "diet", "meal", "breakfast", "lunch", "dinner"],
      "medical": true,
      "sentences": [
        { "text": "Meals built around vegetables, dal, whole grains and some protein tend to release energy more steadily.", "cite": "food-1" },
        { "text": "Regular meal times can help too.", "cite": "food-2" }
      ]
    },
    {
      "key": "sleep_stress",
      "keywords": ["sleep", "insomnia", "stress", "anxious", "relax", "calm"],
      "medical": true,
      "sentences": [
        { "text": "A regular bedtime, a dark and cool room and putting screens away before bed all support sleep.", "cite": "sleep-1" },
        { "text": "Slow breathing, with a longer out-breath, is a simple way to help your body relax.", "cite": "sleep-2" }
      ]
    },
    {
      "key": "specialist_guide",
      "keywords": ["which specialist", "which doctor", "what kind of doctor", "who should i see", "specialist"],
      "medical": false,
      "sentences": [
        { "text": "For cycle and hormone concerns, a gynaecologist is usually the right kind of specialist to start with. For food and weight questions, a registered dietitian can help." },
        { "text": "You can find both under Find a specialist." }
      ]
    }
  ],
  "starters": {
    "byPhase": {
      "menstrual": "What can help on the first days of my period?",
      "follicular": "What should I eat for steady energy?",
      "ovulatory": "Is my cycle length normal?",
      "luteal": "Why do I feel tired before my period?",
      "none": "Is my cycle length normal?"
    },
    "byLog": { "energy:low": "Why am I so tired lately?", "mood:anxious": "How can I calm down when I feel anxious?" },
    "always": ["How can I sleep better?", "Which specialist should I see?"]
  }
}
''';

/// Sample provider accounts, invite and breached-password list (spec 003). Sample-only shortcuts.
const String sampleProvidersJson = r'''
{
  "$sample": "SAMPLE provider and admin accounts for building the sign-in and workspace screens (spec 003, spec 001). In sample mode every account uses the password below and accepts any 6-digit authenticator code. This is the kind of shortcut constitution §5.5 forbids in production code; it exists only in sample modules, which production builds exclude.",
  "samplePassword": "niraah-sample-pass",
  "accounts": [
    { "email": "doctor@sample.niraah.in", "role": "doctor", "status": "active", "name": "Dr Ananya Rao", "speciality": "Gynaecology", "registration": "SAMPLE-MCI-00000", "clinicalReviewer": false },
    { "email": "dietitian@sample.niraah.in", "role": "dietitian", "status": "active", "name": "Sunita Balan", "speciality": "Registered dietitian" },
    { "email": "instructor@sample.niraah.in", "role": "instructor", "status": "active", "name": "Kavya Reddy", "speciality": "Yoga and breathwork" },
    { "email": "pending@sample.niraah.in", "role": "doctor", "status": "under_review", "name": "Dr Meera Pillai", "speciality": "Endocrinology", "missing": ["Registration certificate", "Two professional references"] }
  ],
  "invites": [
    { "token": "sample-invite-doctor", "email": "new.doctor@sample.niraah.in", "role": "doctor", "name": "Dr Kavitha Iyer" }
  ],
  "breachedPasswords": ["password1234", "123456789012", "qwertyuiopas", "niraah123456", "iloveyou1234"]
}
''';

/// Sample doctor workspace data (spec 011, spec 007 §7).
const String sampleDoctorJson = r'''
{
  "$sample": "SAMPLE doctor workspace data (spec 011, spec 007 §7). Every member here is on a paid plan that includes doctor review, so the doctor may see her (spec 011 AC1, AC2). Names are invented. AI clinician summaries are canned text standing in for spec 009's prescore_summary; NOT clinically reviewed.",
  "onCall": { "now": false, "nextFrom": "18:00", "nextTo": "22:00" },
  "reviewTargetHours": { "default": 24, "urgent": 2 },
  "claimMinutes": 30,
  "appointments": [
    { "id": "apt-1", "time": "10:30", "member": "Priya S.", "reason": "Irregular cycles, follow-up", "joinOpensMinutesBefore": 10 },
    { "id": "apt-2", "time": "12:00", "member": "Neha K.", "reason": "First consult" },
    { "id": "apt-3", "time": "16:30", "member": "Ritu M.", "reason": "Lab results discussion" }
  ],
  "consentCategories": ["Assessment", "Cycle and symptoms", "Meals", "Lab reports", "Messages"],
  "reviews": [
    {
      "id": "rev-1", "member": "Aisha F.", "ageBand": "25–30", "plan": "Essential", "submittedHoursAgo": 1, "dedicatedToMe": false,
      "total": 35, "band": "Needs care",
      "flags": [{ "key": "heavy_bleeding", "name": "Heavy bleeding", "severity": "urgent" }, { "key": "missed_periods_3_plus", "name": "Missed periods (3+ months)", "severity": "attention" }],
      "dimensions": [{ "name": "Cycle", "points": 0, "max": 10, "level": "Needs care" }, { "name": "Metabolic", "points": 9, "max": 30, "level": "Needs care" }, { "name": "Mind", "points": 9, "max": 20, "level": "Steady" }, { "name": "Rest", "points": 3, "max": 10, "level": "Needs care" }],
      "summary": "Reports cycles that are rarely present, with the last period over three months ago, and very heavy bleeding when periods occur. Tired most days, sleep often unrefreshing. Diet often rushed. Consent given for review.",
      "observations": ["Your answers suggest a doctor's view would be helpful.", "It has been a while since your last period. That's worth mentioning to a doctor.", "Very heavy bleeding is something a doctor should look at."],
      "consent": ["Assessment", "Cycle and symptoms"],
      "answers": [
        { "q": "How regular is your cycle?", "a": "I rarely get a period" }, { "q": "How long since your last period?", "a": "Three months or more" },
        { "q": "How have you been feeling most days?", "a": "Tired" }, { "q": "Have you noticed any of these lately?", "a": "Very heavy bleeding, Acne or oily skin" },
        { "q": "What does a usual day of eating look like?", "a": "Often rushed or skipped meals" }, { "q": "How active are you in a typical week?", "a": "A little" },
        { "q": "How heavy has stress felt lately?", "a": "Heavy" }, { "q": "How do you usually sleep?", "a": "I often wake up tired" },
        { "q": "What would you most like help with?", "a": "Managing PCOS" }
      ]
    },
    {
      "id": "rev-2", "member": "Divya R.", "ageBand": "31–35", "plan": "Premium", "submittedHoursAgo": 20, "dedicatedToMe": true,
      "total": 62, "band": "Optimizing",
      "flags": [{ "key": "trying_to_conceive", "name": "Trying to conceive", "severity": "information" }],
      "dimensions": [{ "name": "Cycle", "points": 7, "max": 10, "level": "Strong" }, { "name": "Metabolic", "points": 13, "max": 30, "level": "Steady" }, { "name": "Mind", "points": 13, "max": 20, "level": "Steady" }, { "name": "Rest", "points": 6, "max": 10, "level": "Steady" }],
      "summary": "Cycles sometimes early or late. Mostly home food with some snacking; active sometimes. Moderate stress, light sleep. Planning a pregnancy.",
      "observations": ["A few small changes could make your days feel easier.", "You're planning a pregnancy. We can guide you through each step."],
      "consent": ["Assessment", "Cycle and symptoms", "Meals"],
      "answers": [
        { "q": "How regular is your cycle?", "a": "Sometimes early or late" }, { "q": "How have you been feeling most days?", "a": "Up and down" },
        { "q": "Have you noticed any of these lately?", "a": "Weight changes" }, { "q": "What does a usual day of eating look like?", "a": "Mostly home food, some snacking" },
        { "q": "How active are you in a typical week?", "a": "Sometimes" }, { "q": "How heavy has stress felt lately?", "a": "Noticeable" },
        { "q": "How do you usually sleep?", "a": "Okay, but light" }, { "q": "What would you most like help with?", "a": "Planning a pregnancy" }
      ]
    },
    {
      "id": "rev-3", "member": "Meghna T.", "ageBand": "18–24", "plan": "Essential", "submittedHoursAgo": 6, "dedicatedToMe": false,
      "total": 54, "band": "Building",
      "flags": [{ "key": "pregnant", "name": "Pregnant", "severity": "attention" }],
      "dimensions": [{ "name": "Cycle", "points": 8, "max": 10, "level": "Strong" }, { "name": "Metabolic", "points": 10, "max": 30, "level": "Needs care" }, { "name": "Mind", "points": 9, "max": 20, "level": "Steady" }, { "name": "Rest", "points": 3, "max": 10, "level": "Needs care" }],
      "summary": "Reports being pregnant. Often rushed meals, rarely active. Anxious most days; often wakes tired.",
      "observations": ["Some of your answers point to areas where gentle support could help.", "You told us you're pregnant. We'll keep your suggestions pregnancy-safe."],
      "consent": ["Assessment"],
      "answers": [
        { "q": "How regular is your cycle?", "a": "I'm pregnant" }, { "q": "How have you been feeling most days?", "a": "Anxious" },
        { "q": "What does a usual day of eating look like?", "a": "Often rushed or skipped meals" }, { "q": "How active are you in a typical week?", "a": "Rarely" },
        { "q": "How heavy has stress felt lately?", "a": "Noticeable" }, { "q": "How do you usually sleep?", "a": "I often wake up tired" }
      ]
    },
    {
      "id": "rev-4", "member": "Sana Q.", "ageBand": "25–30", "plan": "Foundation", "submittedHoursAgo": 30, "dedicatedToMe": false,
      "total": 81, "band": "Thriving",
      "flags": [],
      "dimensions": [{ "name": "Cycle", "points": 10, "max": 10, "level": "Strong" }, { "name": "Metabolic", "points": 24, "max": 30, "level": "Strong" }, { "name": "Mind", "points": 14, "max": 20, "level": "Strong" }, { "name": "Rest", "points": 6, "max": 10, "level": "Steady" }],
      "summary": "Regular cycles, balanced home-cooked meals, active most days. Light sleep. No flags.",
      "observations": ["Your answers show steady routines you can build on."],
      "consent": ["Assessment", "Cycle and symptoms", "Meals", "Lab reports"],
      "answers": [
        { "q": "How regular is your cycle?", "a": "Like clockwork, every 21 to 35 days" }, { "q": "How have you been feeling most days?", "a": "Energetic" },
        { "q": "Have you noticed any of these lately?", "a": "None of these" }, { "q": "What does a usual day of eating look like?", "a": "Home-cooked and balanced" },
        { "q": "How active are you in a typical week?", "a": "Most days" }, { "q": "How do you usually sleep?", "a": "Okay, but light" }
      ]
    }
  ]
}
''';
