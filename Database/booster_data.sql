UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_META', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_UI', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_SEC_PERM', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_INF_SETTING', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_INF_MSG', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_SEC_POLICY', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_SEC_PROV', 'BFW', 0, NULL)
                     ;
UPDATE OR INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION)
                       VALUES ('BFW_SEC_USER', 'BFW', 0, NULL)
                     ;

COMMIT WORK;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_SETTING', 'META', 'select * from bfw_inf_settings_meta order by title', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_SETTING', 'GET', 'select * from bfw_inf_ev_setting_get(:name, :username)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_SETTING', 'CHECK', 'select * from bfw_inf_ev_setting_check(:name, :username)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_POLICY', 'List', 'select * from bfw_sec_ev_policy_list(:ParentID) order by name', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_USER', 'List', 'select userid, name, isrole from bfw_sec_users order by name', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PERM', 'List', 'select * from bfw_sec_ev_perm_list(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_USER', 'Item', 'select userid, name, isrole from bfw_sec_users where userid= :userid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PERM', 'Effective', 'select * from bfw_sec_ev_perm_effective(:polid, :permid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_UI', 'List', 'select * from bfw_ui_ev_list', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_UI', 'Commands', 'select * from bfw_ui_cmd where uri = :uri order by idx', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PROV', 'List', 'select * from bfw_sec_prov', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_UI', 'Styles', 'select * from bfw_ui_styles', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'Entities', 'select entityname from bfw_ent', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'Fields', 'select * from bfw_ent_fields where entityname = :entityname and viewname = :viewname', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'Entity', 'select * from bfw_ent where entityname = :entityname', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'View', 'select * from bfw_ent_views where entityname = :entityname and viewname = :viewname', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'ViewLinks', 'select * from bfw_ent_view_links where entityname = :entityname and viewname = :viewname', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_META', 'ViewLinkedFields', 'select * from bfw_ent_view_links  where linked_entityname = :entityname and linked_viewname = :viewname and coalesce(linked_field, '''') <> ''''', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_SETTING', 'SET', 'execute procedure bfw_inf_ev_setting_set(:name, :username, :vali, :vals, :valn, :vald)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_USER', 'UserRoleCheck', 'select count(*) status from bfw_sec_user_roles  where userid = :userid and roleid = :roleid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PERM', 'StateGet', 'select state from bfw_sec_ev_perm_state_get(:permid, :userid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_POLICY', 'StateGet', 'select state from bfw_sec_ev_policy_state_get(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PERM', 'StateSet', 'execute procedure bfw_sec_ev_perm_state_set(:permid, :userid, :resid, :state)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_POLICY', 'StateSet', 'execute procedure bfw_sec_ev_policy_state_set(:polid, :state)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_USER', 'UserRoleAdd', 'insert into bfw_sec_user_roles(userid, roleid) values(:userid, :roleid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_USER', 'UserRoleRemove', 'delete from bfw_sec_user_roles where userid = :userid and roleid = :roleid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_PERM', 'Check', 'select state from bfw_sec_sp_perm_check(:permid, :userid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_SEC_POLICY', 'Reset', 'execute procedure bfw_sec_ev_policy_reset(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_MSG', 'POP', 'select * from bfw_inf_sp_msg_pop(:last_id)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_MSG', 'PUSH', 'execute procedure bfw_inf_sp_msg_push(:receiver, :topic, :txt)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;
UPDATE OR INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF)
                             VALUES ('BFW_INF_MSG', 'MARK', 'update bfw_inf_msg set status = 1 where id = :id', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL)
                           ;

COMMIT WORK;
