DROP INDEX IF EXISTS event_logs_name_is_cody_explanation_event;

DROP INDEX IF EXISTS event_logs_name_is_cody_generation_event;

DROP INDEX IF EXISTS event_logs_name_is_cody_active_event;

DROP FUNCTION IF EXISTS isCodyGenerationEvent(name text);

DROP FUNCTION IF EXISTS isCodyExplanationEvent(name text);

DROP FUNCTION IF EXISTS isCodyActiveEvent(name text);
