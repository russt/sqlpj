-- this statement used to elicit "Newline in left-justified string for printf" warning.
-- see newline_bug.pl
select id,name,description,job_name_template,resource_name,workspace_name,property_sheet_id,description_clob_id,job_name_template_clob_id,project_id from ec_procedure where id = 9979
;
