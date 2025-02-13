CREATE OR REPLACE FUNCTION iscodyactiveevent(name text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN
    (name LIKE '%%cody%%' OR name LIKE '%%Cody%%')
    AND name NOT IN (
        '%completion:started%',
        '%completion:suggested%',
        '%cta%',
        '%Cta%',
        'CodyVSCodeExtension:CodySavedLogin:executed',
        'web:codyChat:tryOnPublicCode',
        'web:codyEditorWidget:viewed',
        'web:codyChat:pageViewed',
        'CodyConfigurationPageViewed',
        'ClickedOnTryCodySearchCTA',
        'TryCodyWebOnboardingDisplayed',
        'AboutGetCodyPopover',
        'TryCodyWeb',
        'CodySurveyToastViewed',
        'SiteAdminCodyPageViewed',
        'CodyUninstalled',
        'SpeakToACodyEngineerCTA'
    );
END;
$$;

CREATE OR REPLACE FUNCTION iscodyexplanationevent(name text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN name = ANY(ARRAY[
    'CodyVSCodeExtension:recipe:explain-code-high-level:executed',
    'CodyVSCodeExtension:recipe:explain-code-detailed:executed',
    'CodyVSCodeExtension:recipe:find-code-smells:executed',
    'CodyVSCodeExtension:recipe:git-history:executed',
    'CodyVSCodeExtension:recipe:rate-code:executed'
  ]);
END;
$$;

CREATE OR REPLACE FUNCTION iscodygenerationevent(name text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN name = ANY(ARRAY[
    'CodyVSCodeExtension:recipe:rewrite-to-functional:executed',
    'CodyVSCodeExtension:recipe:improve-variable-names:executed',
    'CodyVSCodeExtension:recipe:replace:executed',
    'CodyVSCodeExtension:recipe:generate-docstring:executed',
    'CodyVSCodeExtension:recipe:generate-unit-test:executed',
    'CodyVSCodeExtension:recipe:rewrite-functional:executed',
    'CodyVSCodeExtension:recipe:code-refactor:executed',
    'CodyVSCodeExtension:recipe:fixup:executed',
	'CodyVSCodeExtension:recipe:translate-to-language:executed'
  ]);
END;
$$;

CREATE INDEX IF NOT EXISTS event_logs_name_is_cody_explanation_event ON event_logs USING btree (iscodyexplanationevent(name));

CREATE INDEX IF NOT EXISTS event_logs_name_is_cody_generation_event ON event_logs USING btree (iscodygenerationevent(name));

CREATE INDEX IF NOT EXISTS event_logs_name_is_cody_active_event ON event_logs USING btree (iscodyactiveevent(name));
