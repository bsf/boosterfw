/******************************************************************************/
/***          Generated by IBExpert 2012.03.13 01.06.2012 7:52:26           ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/


/******************************************************************************/
/***                               Exceptions                               ***/
/******************************************************************************/

CREATE EXCEPTION BFW_SEC_RAISE 'ERROR';



SET TERM ^ ; 



/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/

CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_EFFECTIVE (
    POLID_ VARCHAR(38),
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    USERID VARCHAR(38),
    USERNAME VARCHAR(50),
    PERM VARCHAR(50),
    STATE INTEGER,
    INHERITBY_PERM VARCHAR(50),
    INHERITBY_RESID VARCHAR(38))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_EFFECTIVE_ (
    PERMID_ VARCHAR(38),
    USERID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER,
    PERMID VARCHAR(38),
    RESID VARCHAR(38))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_LIST (
    POLID VARCHAR(38))
RETURNS (
    PERMID VARCHAR(38),
    NAME VARCHAR(50),
    DESCRIPTION VARCHAR(250),
    INHERITBY VARCHAR(50))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_STATE_GET (
    PERMID VARCHAR(38),
    USERID VARCHAR(38),
    RESID VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_STATE_SET (
    PERMID VARCHAR(38),
    USERID VARCHAR(38),
    RESID VARCHAR(38),
    STATE INTEGER)
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_LIST (
    PARENTID VARCHAR(38))
RETURNS (
    POLID VARCHAR(38),
    NAME VARCHAR(50),
    RES_PROVID VARCHAR(38))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_RESET (
    POLID_ VARCHAR(38))
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_STATE_GET (
    POLID VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_STATE_SET (
    POLID VARCHAR(38),
    STATE INTEGER)
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_CHECK (
    PERMID_ VARCHAR(38),
    USERID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
AS
BEGIN
  EXIT;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND_USERS (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    USERID VARCHAR(38))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND2 (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_LEN (
    STRG_IN VARCHAR(1024))
RETURNS (
    STRG_LEN INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_REPLACE (
    STR_IN VARCHAR(1024),
    STR_SEARCH VARCHAR(1024),
    STR_REPLACE VARCHAR(1024))
RETURNS (
    STR_OUT VARCHAR(1024))
AS
BEGIN
  SUSPEND;
END^





CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_SUB (
    STR_IN VARCHAR(1024),
    STR_BEG INTEGER,
    STR_LEN INTEGER)
RETURNS (
    STR_OUT VARCHAR(1024))
AS
BEGIN
  SUSPEND;
END^






SET TERM ; ^



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE BFW_SEC_ACL (
    PERMID  VARCHAR(38) NOT NULL,
    USERID  VARCHAR(38) NOT NULL,
    RESID   VARCHAR(38) NOT NULL,
    STATE   INTEGER NOT NULL
);


CREATE TABLE BFW_SEC_PERMISSIONS (
    PERMID       VARCHAR(38) NOT NULL,
    NAME         VARCHAR(50) NOT NULL,
    POLID        VARCHAR(38) NOT NULL,
    INHERITBY    VARCHAR(38),
    DESCRIPTION  VARCHAR(250)
);


CREATE TABLE BFW_SEC_POLICIES (
    POLID           VARCHAR(38) NOT NULL,
    NAME            VARCHAR(50) NOT NULL,
    PARENTID        VARCHAR(38),
    STATE           INTEGER NOT NULL,
    USE_RES         INTEGER NOT NULL,
    RES_PROVID      VARCHAR(38),
    RES_PARENT_SQL  VARCHAR(1024)
);


CREATE TABLE BFW_SEC_PROV (
    URI         VARCHAR(50) NOT NULL,
    ENTITYNAME  VARCHAR(50) NOT NULL
);


CREATE TABLE BFW_SEC_USER_ROLES (
    USERID  VARCHAR(38) NOT NULL,
    ROLEID  VARCHAR(38) NOT NULL
);


CREATE TABLE BFW_SEC_USERS (
    USERID  VARCHAR(38) NOT NULL,
    NAME    VARCHAR(50) NOT NULL,
    ISROLE  INTEGER DEFAULT 0 NOT NULL
);


INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION) VALUES ('BFW_SEC_PERM', 'BFW_SEC', 0, NULL);
INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION) VALUES ('BFW_SEC_POLICY', 'BFW_SEC', 0, NULL);
INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION) VALUES ('BFW_SEC_PROV', 'BFW_SEC', 0, NULL);
INSERT INTO BFW_ENT (ENTITYNAME, SCHEMENAME, IS_SCHEME, DESCRIPTION) VALUES ('BFW_SEC_USER', 'BFW_SEC', 0, NULL);

COMMIT WORK;

INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_POLICY', 'List', 'select * from bfw_sec_ev_policy_list(:ParentID) order by name', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_USER', 'List', 'select userid, name, isrole from bfw_sec_users order by name', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PERM', 'List', 'select * from bfw_sec_ev_perm_list(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_USER', 'Item', 'select userid, name, isrole from bfw_sec_users where userid= :userid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PERM', 'Effective', 'select * from bfw_sec_ev_perm_effective(:polid, :permid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PROV', 'List', 'select * from bfw_sec_prov', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_USER', 'UserRoleCheck', 'select count(*) status from bfw_sec_user_roles  where userid = :userid and roleid = :roleid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PERM', 'StateGet', 'select state from bfw_sec_ev_perm_state_get(:permid, :userid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_POLICY', 'StateGet', 'select state from bfw_sec_ev_policy_state_get(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PERM', 'StateSet', 'execute procedure bfw_sec_ev_perm_state_set(:permid, :userid, :resid, :state)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_POLICY', 'StateSet', 'execute procedure bfw_sec_ev_policy_state_set(:polid, :state)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_USER', 'UserRoleAdd', 'insert into bfw_sec_user_roles(userid, roleid) values(:userid, :roleid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_USER', 'UserRoleRemove', 'delete from bfw_sec_user_roles where userid = :userid and roleid = :roleid', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_PERM', 'Check', 'select state from bfw_sec_sp_perm_check(:permid, :userid, :resid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 0, NULL);
INSERT INTO BFW_ENT_VIEWS (ENTITYNAME, VIEWNAME, SQL_SELECT, SQL_INSERT, SQL_UPDATE, SQL_DELETE, SQL_REFRESH, READONLY, PKEY, OPTIONS, IS_EXEC, SQL_INSERTDEF) VALUES ('BFW_SEC_POLICY', 'Reset', 'execute procedure bfw_sec_ev_policy_reset(:polid)', NULL, NULL, NULL, NULL, 1, NULL, NULL, 1, NULL);

COMMIT WORK;

INSERT INTO BFW_SEC_USERS (USERID, NAME, ISROLE) VALUES ('SYSDBA', '�����. ��', 0);

COMMIT WORK;

INSERT INTO BFW_SEC_POLICIES (POLID, NAME, PARENTID, STATE, USE_RES, RES_PROVID, RES_PARENT_SQL) VALUES ('BUILT-IN', '��������������', NULL, 1, 0, NULL, NULL);

COMMIT WORK;

INSERT INTO BFW_SEC_PERMISSIONS (PERMID, NAME, POLID, INHERITBY, DESCRIPTION) VALUES ('builtin.unrestricted', '�������������� ������', 'BUILT-IN', NULL, NULL);

COMMIT WORK;

INSERT INTO BFW_SEC_ACL (PERMID, USERID, RESID, STATE) VALUES ('builtin.unrestricted', 'SYSDBA', '', 1);

COMMIT WORK;



/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE BFW_SEC_ACL ADD CONSTRAINT PK_BFW_SEC_ACL PRIMARY KEY (PERMID, USERID, RESID);
ALTER TABLE BFW_SEC_PERMISSIONS ADD CONSTRAINT PK_BFW_SEC_PERMISSIONS PRIMARY KEY (PERMID);
ALTER TABLE BFW_SEC_POLICIES ADD CONSTRAINT PK_BFW_SEC_POLICIES PRIMARY KEY (POLID);
ALTER TABLE BFW_SEC_PROV ADD CONSTRAINT PK_BFW_SEC_PROV PRIMARY KEY (URI);
ALTER TABLE BFW_SEC_USERS ADD CONSTRAINT PK_BFW_SEC_USERS PRIMARY KEY (USERID);
ALTER TABLE BFW_SEC_USER_ROLES ADD CONSTRAINT PK_BFW_SEC_USER_ROLES PRIMARY KEY (USERID, ROLEID);


/******************************************************************************/
/***                              Foreign Keys                              ***/
/******************************************************************************/

ALTER TABLE BFW_SEC_ACL ADD CONSTRAINT FK_BFW_SEC_ACL_PERM FOREIGN KEY (PERMID) REFERENCES BFW_SEC_PERMISSIONS (PERMID);
ALTER TABLE BFW_SEC_ACL ADD CONSTRAINT FK_BFW_SEC_ACL_USERID FOREIGN KEY (USERID) REFERENCES BFW_SEC_USERS (USERID);
ALTER TABLE BFW_SEC_PERMISSIONS ADD CONSTRAINT FK_BFW_SEC_PERMISSIONS_INHERITB FOREIGN KEY (INHERITBY) REFERENCES BFW_SEC_PERMISSIONS (PERMID);
ALTER TABLE BFW_SEC_PERMISSIONS ADD CONSTRAINT FK_BFW_SEC_PERMISSIONS_POLID FOREIGN KEY (POLID) REFERENCES BFW_SEC_POLICIES (POLID);
ALTER TABLE BFW_SEC_POLICIES ADD CONSTRAINT FK_BFW_SEC_POLICIES_PARENT FOREIGN KEY (PARENTID) REFERENCES BFW_SEC_POLICIES (POLID);
ALTER TABLE BFW_SEC_USER_ROLES ADD CONSTRAINT FK_BFW_SEC_USER_ROLES_ROLEID FOREIGN KEY (ROLEID) REFERENCES BFW_SEC_USERS (USERID);
ALTER TABLE BFW_SEC_USER_ROLES ADD CONSTRAINT FK_BFW_SEC_USER_ROLES_USERID FOREIGN KEY (USERID) REFERENCES BFW_SEC_USERS (USERID);


/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: BFW_SEC_PERMISSIONS_BD */
CREATE OR ALTER TRIGGER BFW_SEC_PERMISSIONS_BD FOR BFW_SEC_PERMISSIONS
ACTIVE BEFORE DELETE POSITION 0
as
begin
  delete from bfw_sec_acl a where a.permid = old.permid;
end
^


/* Trigger: BFW_SEC_POLICIES_BD */
CREATE OR ALTER TRIGGER BFW_SEC_POLICIES_BD FOR BFW_SEC_POLICIES
ACTIVE BEFORE DELETE POSITION 0
as
begin
  if (old.polid = 'BUILD-IN') then
    exception bfw_sec_raise 'It is not allowed for built-in policy';
end
^


/* Trigger: BFW_SEC_POLICIES_BU */
CREATE OR ALTER TRIGGER BFW_SEC_POLICIES_BU FOR BFW_SEC_POLICIES
ACTIVE BEFORE UPDATE POSITION 0
as
begin
  if (new.polid = 'BUILT-IN' and new.state <> old.state and new.state = 0) then
    exception bfw_sec_raise 'It is not allowed for built-in policy';
end
^


/* Trigger: BFW_SEC_USERS_BD */
CREATE OR ALTER TRIGGER BFW_SEC_USERS_BD FOR BFW_SEC_USERS
ACTIVE BEFORE DELETE POSITION 0
as
begin
  delete from bfw_sec_acl a where a.userid = old.userid;
  delete from bfw_sec_user_roles r where r.userid = old.userid;
  delete from bfw_sec_user_roles r where r.roleid = old.userid;
end
^


/* Trigger: BFW_SEC_USERS_BI */
CREATE OR ALTER TRIGGER BFW_SEC_USERS_BI FOR BFW_SEC_USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.name is null) then
    new.name = new.userid;
end
^


/* Trigger: BFW_SEC_USERS_BU */
CREATE OR ALTER TRIGGER BFW_SEC_USERS_BU FOR BFW_SEC_USERS
ACTIVE BEFORE UPDATE POSITION 0
as
begin
  if (new.name is null) then
    new.name = new.userid;
end
^


SET TERM ; ^



/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/


SET TERM ^ ;

CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_EFFECTIVE (
    POLID_ VARCHAR(38),
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    USERID VARCHAR(38),
    USERNAME VARCHAR(50),
    PERM VARCHAR(50),
    STATE INTEGER,
    INHERITBY_PERM VARCHAR(50),
    INHERITBY_RESID VARCHAR(38))
AS
declare variable permcheck varchar(38);
declare variable permid varchar(38);
declare variable resid varchar(38);
begin
  permid_ = nullif(permid_, '');
  for
    select userid, name
    from bfw_sec_users
    into :userid, :username
  do begin
    for
      select p.permid, p.name
      from bfw_sec_policies pl left join bfw_sec_permissions p  on (pl.polid = p.polid)
      where pl.polid = :polid_
            and ((:permid_ is null) or (:permid_ is not null and p.permid = :permid_))
      into :permcheck, :perm
    do begin
      state = null;
      inheritby_perm = null;
      inheritby_resid = null;
      permid = null;
      resid = null;
      select p.state, p.permid, p.resid
      from bfw_sec_ev_perm_effective_(:permcheck, :userid, :resid_) p
      into :state, :permid, :resid;
      if (state is not null) then
      begin
        if (permid <> permcheck) then
          select name from bfw_sec_permissions p
          where p.permid = :permid
          into :inheritby_perm;

        if (coalesce(resid, resid_) <> resid_) then
          inheritby_resid = resid;

        suspend;
      end
    end
  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_EFFECTIVE_ (
    PERMID_ VARCHAR(38),
    USERID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER,
    PERMID VARCHAR(38),
    RESID VARCHAR(38))
AS
declare variable inheritby varchar(38);
declare variable parent_resid varchar(38);
declare variable res_parent_sql varchar(1024);
begin
  resid_ = coalesce(resid_, '');
  permid = permid_;
  resid = resid_;

  for
    select a.state
    from bfw_sec_acl a
    where a.resid = :resid_ and a.userid = :userid_ and a.permid = :permid_
    into :state
  do
    if (state in (1, 2)) then
    begin
      suspend;
      exit;
    end

  select p.inheritby, pol.res_parent_sql
  from bfw_sec_permissions p left join bfw_sec_policies pol on (pol.polid = p.polid)
  where p.permid = :permid_
  into :inheritby, :res_parent_sql;

  if (inheritby is null and res_parent_sql is null) then
  begin
    exit;
  end

  parent_resid = '';
  if (coalesce(res_parent_sql, '') <> '') then
  begin
    res_parent_sql = upper(res_parent_sql);
    execute procedure bfw_sec_sp_string_replace(:res_parent_sql, ':RESID', :resid_)
    returning_values :res_parent_sql;
    execute statement res_parent_sql into :parent_resid;
    parent_resid = coalesce(parent_resid, '');

    if (parent_resid <> '') then
      inheritby = permid_;

  end

  if (inheritby is not null) then
  begin
    select state, permid, resid from bfw_sec_ev_perm_effective_(:inheritby, :userid_, :parent_resid)
    into :state, :permid, :resid;

    if (state in (1, 2)) then
      suspend;
  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_LIST (
    POLID VARCHAR(38))
RETURNS (
    PERMID VARCHAR(38),
    NAME VARCHAR(50),
    DESCRIPTION VARCHAR(250),
    INHERITBY VARCHAR(50))
AS
begin
  for
    select p.permid, p.name, p.description, pi.name
    from bfw_sec_permissions p
         left join bfw_sec_permissions pi on (p.inheritby = pi.permid)
    where p.polid = :polid
    into :permid, :name, :description, :inheritby
  do
    suspend;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_STATE_GET (
    PERMID VARCHAR(38),
    USERID VARCHAR(38),
    RESID VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
begin
  resid = coalesce(resid, '');
  select state
  from bfw_sec_acl p
  where p.resid = :resid and p.userid = :userid and p.permid = :permid
  into :state;
  state = coalesce(state, 0);
  suspend;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_PERM_STATE_SET (
    PERMID VARCHAR(38),
    USERID VARCHAR(38),
    RESID VARCHAR(38),
    STATE INTEGER)
AS
begin
  resid = coalesce(resid, '');

  if (state = 0) then
    delete from bfw_sec_acl p
       where p.resid = :resid and p.userid = :userid and p.permid = :permid;
  else
  begin
    if (exists(select * from bfw_sec_acl p
              where p.resid = :resid
                    and p.userid = :userid and p.permid = :permid)) then
     update bfw_sec_acl p
     set p.state = :state
     where p.resid = :resid and p.userid = :userid and p.permid = :permid;
    else
      insert into bfw_sec_acl(resid, userid, permid, state)
      values (:resid, :userid, :permid, :state);
  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_LIST (
    PARENTID VARCHAR(38))
RETURNS (
    POLID VARCHAR(38),
    NAME VARCHAR(50),
    RES_PROVID VARCHAR(38))
AS
begin
  for
    select p.polid, p.name, p.res_provid
    from bfw_sec_policies p
    where p.parentid is null and coalesce(:parentid, '') = ''
    union all
    select p.polid, p.name, p.res_provid
    from bfw_sec_policies p
    where p.parentid = :parentid and coalesce(:parentid, '') <> ''
    into :polid, :name, :res_provid
  do
    suspend;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_RESET (
    POLID_ VARCHAR(38))
AS
begin
  delete from bfw_sec_acl a
  where a.permid in (select p.permid from bfw_sec_permissions p where p.polid = :polid_);
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_STATE_GET (
    POLID VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
begin
  select state
  from bfw_sec_policies p where p.polid= :polid
  into :state;
  state = coalesce(state, 0);
  suspend;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_EV_POLICY_STATE_SET (
    POLID VARCHAR(38),
    STATE INTEGER)
AS
begin
  update bfw_sec_policies p
  set p.state = :state
  where p.polid = :polid;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_CHECK (
    PERMID_ VARCHAR(38),
    USERID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
declare variable unrestricted_perm varchar(38) = 'builtin.unrestricted' ;
declare variable pol_state integer;
declare variable roleid varchar(38);
declare variable parent_permid varchar(38);
declare variable parent_resid varchar(38);
declare variable res_parent_sql varchar(1024);
begin
  resid_ = coalesce(resid_, '');

  select a.state
  from bfw_sec_acl a
  where a.permid = :unrestricted_perm and a.userid = :userid_ and a.resid = ''
        and a.state = 1
  into :state;

  if (coalesce(state, 0) = 1) then
  begin
    suspend;
    exit;
  end

  select first 1 a.state
  from bfw_sec_acl a
       left join bfw_sec_user_roles r on (a.userid = r.roleid)
  where a.permid = :unrestricted_perm and r.userid = :userid_ and a.resid = ''
        and a.state = 1
  into :state;

  if (coalesce(state, 0) = 1) then
  begin
    suspend;
    exit;
  end

  select p.inheritby, pol.res_parent_sql, pol.state
  from bfw_sec_permissions p left join bfw_sec_policies pol on (pol.polid = p.polid)
  where p.permid = :permid_
  into :parent_permid, :res_parent_sql, :pol_state;

  if (pol_state <> 1) then
  begin
    state = 1;
    suspend;
    exit;
  end

  for
    select a.state
    from bfw_sec_acl a
    where a.resid = :resid_ and a.userid = :userid_ and a.permid = :permid_
    into :state
  do
    if (state in (1, 2)) then
    begin
      suspend;
      exit;
    end

  for
    select r.roleid
    from bfw_sec_user_roles r
    where r.userid = :userid_
    into :roleid
  do begin
    select a.state
    from bfw_sec_acl a
    where a.resid = :resid_ and a.userid = :roleid and a.permid = :permid_
    into :state;

    if (state in (1, 2)) then
    begin
      suspend;
      exit;
    end
  end

  if (parent_permid is null and res_parent_sql is null) then
  begin
    state = 0;
    suspend;
    exit;
  end

  parent_resid = '';
  if (coalesce(res_parent_sql, '') <> '') then
  begin
    res_parent_sql = upper(res_parent_sql);
    execute procedure bfw_sec_sp_string_replace(:res_parent_sql, ':RESID', :resid_)
    returning_values :res_parent_sql;
    execute statement res_parent_sql into :parent_resid;
    parent_resid = coalesce(parent_resid, '');

    if (parent_resid <> '') then
      parent_permid = permid_;

  end

  if (parent_permid is not null) then
  begin
    select state from bfw_sec_sp_perm_check(:parent_permid, :userid_, :parent_resid)
    into :state;
    suspend;
    exit;
  end
  else
  begin
    state = 0;
    suspend;
    exit;
  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
AS
declare variable userid  varchar(38);
declare variable pstate integer;
declare variable pname varchar(250);
begin
  userid = user;
  select state from bfw_sec_sp_perm_check(:permid_, :userid, :resid_)
  into :pstate;

  if (pstate <> 1) then
  begin
    select name from bfw_sec_permissions p where p.permid = :permid_
    into :pname;

    pname = coalesce(pname, permid_);

    pname = 'No permission for: ' || pname;
    exception bfw_sec_raise :pname;

  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND_USERS (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    USERID VARCHAR(38))
AS
declare variable state integer;
begin
  for
    select u.userid
    from bfw_sec_users u
    where u.isrole = 0
    into :userid 
  do begin
    select state from bfw_sec_sp_perm_check(:permid_, :userid, :resid_)
    into :state;

    if (state = 1) then suspend;
  end
end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_PERM_DEMAND2 (
    PERMID_ VARCHAR(38),
    RESID_ VARCHAR(38))
RETURNS (
    STATE INTEGER)
AS
declare variable userid  varchar(38);
begin
  userid = user;
  select state from bfw_sec_sp_perm_check(:permid_, :userid, :resid_)
  into :state;
  suspend;
end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_LEN (
    STRG_IN VARCHAR(1024))
RETURNS (
    STRG_LEN INTEGER)
AS
    begin
      /*
        get string length
      */

      if (strg_in is null)
        then
          strg_len = null;
        else
          begin
            strg_len = 0;
            while (strg_in || '.'  <> '.')
              do
                begin
                  strg_in = substring( strg_in from 2);
                  strg_len = strg_len + 1;
                end
          end

      suspend;
    end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_REPLACE (
    STR_IN VARCHAR(1024),
    STR_SEARCH VARCHAR(1024),
    STR_REPLACE VARCHAR(1024))
RETURNS (
    STR_OUT VARCHAR(1024))
AS
declare variable str_beg integer;
declare variable str_comp varchar(1024);
declare variable str_pre varchar(1024);
declare variable str_pst varchar(1024);
declare variable str_len_orig integer;
declare variable str_len_srch integer;
declare variable str_len_repl integer;
begin
  if ((str_in is null) or (str_search is null) or (str_replace is null)) then
  begin
    str_out = null;
    suspend;
    exit;
  end

  execute procedure bfw_sec_sp_string_len :str_in returning_values :str_len_orig;
   -- str_len_orig = strlen(str_in);

  execute procedure bfw_sec_sp_string_len :str_search returning_values :str_len_srch;
    --str_len_srch = strlen(str_search);

  execute procedure bfw_sec_sp_string_len :str_replace  returning_values :str_len_repl;
    --str_len_repl = strlen(str_replace);

  str_beg = 1;
  while (str_len_srch + str_beg - 1 <= str_len_orig) do
  begin
    execute procedure bfw_sec_sp_string_len :str_in returning_values :str_len_orig;
      --str_len_orig = strlen(str_in);


    execute procedure bfw_sec_sp_string_sub :str_in, :str_beg, str_len_srch returning_values :str_comp;

    if (str_comp || '.' = str_search || '.') then
    begin
      execute procedure bfw_sec_sp_string_sub :str_in, 1, :str_beg - 1
        returning_values :str_pre;

      execute procedure bfw_sec_sp_string_sub :str_in, :str_beg + :str_len_srch,
                  :str_len_orig - (:str_beg + :str_len_srch) + 1
                                                         returning_values :str_pst;

      str_in = coalesce(str_pre, '') || str_replace || coalesce(str_pst, '');

      str_beg = str_beg + str_len_repl - str_len_srch;

    end

    str_beg = str_beg + 1;
  end

  str_out = str_in;

  suspend;

end^


CREATE OR ALTER PROCEDURE BFW_SEC_SP_STRING_SUB (
    STR_IN VARCHAR(1024),
    STR_BEG INTEGER,
    STR_LEN INTEGER)
RETURNS (
    STR_OUT VARCHAR(1024))
AS
declare variable str_chr char( 1);
declare variable str_cpy varchar( 1024);

begin
  /*
     get substring
     strg_beg : 1 ..
  */

  if ((str_in is null)
     or (str_beg is null)
     or (str_beg <= 0)
     or (str_len is null)
     or (str_len <= 0))
  then
    str_out = null;
  else
  begin
    str_cpy = str_in;
    while (1 < str_beg) do
    begin
      str_cpy = substring( str_cpy from 2);
      str_beg = str_beg - 1;
    end

    str_out = '';
    while (0 < str_len) do
    begin
      str_chr = substring( str_cpy from 1 for 1);
      if (str_chr || '.' <> '.') then
      begin
        str_out = str_out || str_chr;
        str_cpy = substring( str_cpy from 2);
        str_len = str_len - 1;
      end
      else
      begin
        str_len = 0;
      end
    end
  end

  suspend;
end^



SET TERM ; ^