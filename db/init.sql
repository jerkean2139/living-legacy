-- Leakage Assessment Database Schema
-- Auto-runs on first docker-compose up

-- ── Assessment submissions ──
CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    user_agent TEXT
);

-- ── Leakage answers ──
CREATE TABLE IF NOT EXISTS leakage_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL,
    answer_value VARCHAR(50) NOT NULL,
    leakage_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Gains inputs ──
CREATE TABLE IF NOT EXISTS gains_inputs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    input_key VARCHAR(100) NOT NULL,
    input_value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Calculated results (snapshot at completion) ──
CREATE TABLE IF NOT EXISTS results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL UNIQUE REFERENCES assessments(id) ON DELETE CASCADE,
    monthly_leakage DECIMAL(10,2) NOT NULL DEFAULT 0,
    annual_leakage DECIMAL(10,2) NOT NULL DEFAULT 0,
    monthly_saved DECIMAL(10,2) NOT NULL DEFAULT 0,
    monthly_gained DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_monthly_impact DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_annual_impact DECIMAL(10,2) NOT NULL DEFAULT 0,
    hours_saved_weekly DECIMAL(5,1) NOT NULL DEFAULT 0,
    recommendation VARCHAR(20), -- 'coach', 'caio', 'both'
    severity VARCHAR(20),       -- 'low', 'moderate', 'high', 'critical'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Category breakdowns ──
CREATE TABLE IF NOT EXISTS category_breakdowns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    breakdown_type VARCHAR(20) NOT NULL, -- 'leakage' or 'gains'
    category VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- ── Email captures (for gated content) ──
CREATE TABLE IF NOT EXISTS email_captures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    assessment_id UUID REFERENCES assessments(id) ON DELETE SET NULL,
    source VARCHAR(50) DEFAULT 'email-gate', -- 'email-gate', 'results-unlock', 'cta'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Indexes ──
CREATE INDEX idx_assessments_email ON assessments(email);
CREATE INDEX idx_assessments_created ON assessments(created_at DESC);
CREATE INDEX idx_leakage_answers_assessment ON leakage_answers(assessment_id);
CREATE INDEX idx_gains_inputs_assessment ON gains_inputs(assessment_id);
CREATE INDEX idx_results_assessment ON results(assessment_id);
CREATE INDEX idx_email_captures_email ON email_captures(email);
CREATE INDEX idx_email_captures_created ON email_captures(created_at DESC);
