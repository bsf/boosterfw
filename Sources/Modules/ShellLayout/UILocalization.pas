unit UILocalization;

interface
uses cxClasses, dxNavBarConsts, cxGridStrs, cxFilterControlStrs, cxFilterConsts,
  cxGridPopupMenuConsts;

procedure Localization;

implementation

procedure Localization;
begin
{*-------------------------- NAV BAR -------------------------------------------
  sdxNavigationPaneOverflowPanelCustomizeHint = 'Configure buttons';
  sdxNavigationPaneMinimizeNavPaneSignHint = 'Minimize Navigation Pane';
  sdxNavigationPaneExpandNavPaneSignHint = 'Expand Navigation Pane';
  sdxNavigationPaneCollapseBarHint = 'Click to expand Navigation Pane';
  sdxNavigationPaneCollapseBar = 'Navigation Pane';

//Exception messages

  sdxInvalideGroupControl = 'Invalid the TdxNavBarGroupControl parent or group.';
  sdxInvalidLink = 'You cannot create a link to the ''%s'' item within the ''%s'' group because they belong to different NavBar controls';
  sdxCannotFindView = 'Cannot find view with ID = %d.';
  sdxViewAlreadyExists = 'ID of view = %d is already exists.';

//Office11Views popup menu captions

  sdxNavBarOffice11ShowMoreButtons = 'Show &More Buttons';
  sdxNavBarOffice11ShowFewerButtons = 'Show &Fewer Buttons';
  sdxNavBarOffice11AddRemoveButtons = '&Add or Remove Buttons';
------------------------------------------------------------------------------*}

  cxSetResourceString(@sdxNavigationPaneOverflowPanelCustomizeHint, 'Настройка кнопок');
  cxSetResourceString(@sdxNavigationPaneMinimizeNavPaneSignHint, 'Свернуть область переходов');
  cxSetResourceString(@sdxNavigationPaneExpandNavPaneSignHint, 'Развернуть область переходов');
  cxSetResourceString(@sdxNavigationPaneCollapseBarHint, 'Щелкните для развертывания области переходов');
  cxSetResourceString(@sdxNavigationPaneCollapseBar, 'Область переходов');


{*------------------------ GRID ------------------------------------------------
scxGridRecursiveLevels = 'You cannot create recursive levels';

  scxGridDeletingConfirmationCaption = 'Confirm';
  scxGridDeletingFocusedConfirmationText = 'Delete record?';
  scxGridDeletingSelectedConfirmationText = 'Delete all selected records?';

  scxGridNoDataInfoText = '<No data to display>';

  scxGridFilterRowInfoText = 'Click here to define a filter';
  scxGridNewItemRowInfoText = 'Click here to add a new row';

  scxGridFilterIsEmpty = '<Filter is Empty>';

  scxGridCustomizationFormCaption = 'Customization';
  scxGridCustomizationFormColumnsPageCaption = 'Columns';
  scxGridGroupByBoxCaption = 'Drag a column header here to group by that column';
  scxGridFilterApplyButtonCaption = 'Apply Filter';
  scxGridFilterCustomizeButtonCaption = 'Customize...';
  scxGridColumnsQuickCustomizationHint = 'Click here to show/hide/move columns';

  scxGridCustomizationFormBandsPageCaption = 'Bands';
  scxGridBandsQuickCustomizationHint = 'Click here to show/hide/move bands';

  scxGridCustomizationFormRowsPageCaption = 'Rows';

  scxGridConverterIntermediaryMissing = 'Missing an intermediary component!'#13#10'Please add a %s component to the form.';
  scxGridConverterNotExistGrid = 'cxGrid does not exist';
  scxGridConverterNotExistComponent = 'Component does not exist';
  scxImportErrorCaption = 'Import error';

  scxNotExistGridView = 'Grid view does not exist';
  scxNotExistGridLevel = 'Active grid level does not exist';
  scxCantCreateExportOutputFile = 'Can''t create the export output file';

  cxSEditRepositoryExtLookupComboBoxItem = 'ExtLookupComboBox|Represents an ultra-advanced lookup using the QuantumGrid as its drop down control';

  // date ranges

  scxGridYesterday = 'Yesterday';
  scxGridToday = 'Today';
  scxGridTomorrow = 'Tomorrow';
  scxGridLast30Days = 'Last 30 days';
  scxGridLast14Days = 'Last 14 days';
  scxGridLast7Days = 'Last 7 days';
  scxGridNext7Days = 'Next 7 days';
  scxGridNext14Days = 'Next 14 days';
  scxGridNext30Days = 'Next 30 days';
  scxGridLastTwoWeeks = 'Last two weeks';
  scxGridLastWeek = 'Last week';
  scxGridThisWeek = 'This week';
  scxGridNextWeek = 'Next week';
  scxGridNextTwoWeeks = 'Next two weeks';
  scxGridLastMonth = 'Last month';
  scxGridThisMonth = 'This month';
  scxGridNextMonth = 'Next month';
  scxGridLastYear = 'Last year';
  scxGridThisYear = 'This year';
  scxGridNextYear = 'Next year';
  scxGridPast = 'Past';
  scxGridFuture = 'Future';

  scxGridMonthFormat = 'mmmm yyyy';
  scxGridYearFormat = 'yyyy';

  // ChartView
  
  scxGridChartCategoriesDisplayText = 'Data';

  scxGridChartValueHintFormat = '%s for %s is %s';  // series display text, category, value
  scxGridChartPercentValueTickMarkLabelFormat = '0%';

  scxGridChartToolBoxDataLevels = 'Data Levels:';
  scxGridChartToolBoxDataLevelSelectValue = 'select value';
  scxGridChartToolBoxCustomizeButtonCaption = 'Customize Chart';

  scxGridChartNoneDiagramDisplayText = 'No diagram';
  scxGridChartColumnDiagramDisplayText = 'Column diagram';
  scxGridChartBarDiagramDisplayText = 'Bar diagram';
  scxGridChartLineDiagramDisplayText = 'Line diagram';
  scxGridChartAreaDiagramDisplayText = 'Area diagram';
  scxGridChartPieDiagramDisplayText = 'Pie diagram';

  scxGridChartCustomizationFormSeriesPageCaption = 'Series';
  scxGridChartCustomizationFormSortBySeries = 'Sort by:';
  scxGridChartCustomizationFormNoSortedSeries = '<none series>';
  scxGridChartCustomizationFormDataGroupsPageCaption = 'Data Groups';
  scxGridChartCustomizationFormOptionsPageCaption = 'Options';

  scxGridChartLegend = 'Legend';
  scxGridChartLegendKeyBorder = 'Key Border';
  scxGridChartPosition = 'Position';
  scxGridChartPositionDefault = 'Default';
  scxGridChartPositionNone = 'None';
  scxGridChartPositionLeft = 'Left';
  scxGridChartPositionTop = 'Top';
  scxGridChartPositionRight = 'Right';
  scxGridChartPositionBottom = 'Bottom';
  scxGridChartAlignment = 'Alignment';
  scxGridChartAlignmentDefault = 'Default';
  scxGridChartAlignmentStart = 'Start';
  scxGridChartAlignmentCenter = 'Center';
  scxGridChartAlignmentEnd = 'End';
  scxGridChartOrientation = 'Orientation';
  scxGridChartOrientationDefault = 'Default';
  scxGridChartOrientationHorizontal = 'Horizontal';
  scxGridChartOrientationVertical = 'Vertical';
  scxGridChartBorder = 'Border';
  scxGridChartTitle = 'Title';
  scxGridChartToolBox = 'ToolBox';
  scxGridChartDiagramSelector = 'Diagram Selector';
  scxGridChartOther = 'Other';
  scxGridChartValueHints = 'Value Hints';

------------------------------------------------------------------------------*}

  cxSetResourceString(@scxGridNoDataInfoText, 'Нет данных для отображения');

  cxSetResourceString(@scxGridFilterRowInfoText, 'Щелкните для добавления фильтра');
  cxSetResourceString(@scxGridNewItemRowInfoText, 'Щелкните для добавления строки');

  cxSetResourceString(@scxGridFilterIsEmpty, '<Фильтр пуст>');

  cxSetResourceString(@scxGridCustomizationFormCaption, 'Настройка');
  cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, 'Поля');
  cxSetResourceString(@scxGridGroupByBoxCaption, 'Перетащите поле для группировки');
  cxSetResourceString(@scxGridFilterApplyButtonCaption, 'Применить фильтр');
  cxSetResourceString(@scxGridFilterCustomizeButtonCaption, 'Настройка...');
  cxSetResourceString(@scxGridColumnsQuickCustomizationHint, 'Щелкните что бы отобразить/скрыть/переместить поля');

  cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, 'Группы полей');
  cxSetResourceString(@scxGridBandsQuickCustomizationHint, 'Щелкните что бы отобразить/скрыть/переместить группу полей');

  cxSetResourceString(@scxGridCustomizationFormRowsPageCaption, 'Строки');


(*------------------- GRID POPUPMENU ----------------------------------------
  // Header popup menu item captions

  cxSGridSortColumnAsc = 'Sort Ascending';
  cxSGridSortColumnDesc = 'Sort Descending';
  cxSGridClearSorting = 'Clear Sorting';
  cxSGridGroupByThisField = 'Group By This Field';
  cxSGridRemoveThisGroupItem = 'Remove from grouping';
  cxSGridGroupByBox = 'Group By Box';
  cxSGridAlignmentSubMenu = 'Alignment';
  cxSGridAlignLeft = 'Align Left';
  cxSGridAlignRight = 'Align Right';
  cxSGridAlignCenter = 'Align Center';
  cxSGridRemoveColumn = 'Remove This Column';
  cxSGridFieldChooser = 'Field Chooser';
  cxSGridBestFit = 'Best Fit';
  cxSGridBestFitAllColumns = 'Best Fit (all columns)';
  cxSGridShowFooter = 'Footer';
  cxSGridShowGroupFooter = 'Group Footers';

  // Footer popup menu item captions

  cxSGridNoneMenuItem = 'None';
  cxSGridSumMenuItem = 'Sum';
  cxSGridMinMenuItem = 'Min';
  cxSGridMaxMenuItem = 'Max';
  cxSGridCountMenuItem = 'Count';
  cxSGridAvgMenuItem = 'Average';

  // Group row popup menu item captions

  cxSGridSortByGroupValues = 'Sort by Group Value';
  cxSGridSortBySummaryCaption = 'Sort by Group Summary:';
  cxSGridSortBySummary = '%s for %s';

----------------------------------------------------------------------------*)
  // Header popup menu item captions

  cxSetResourceString(@cxSGridSortColumnAsc, 'Сортировка от А до Я');
  cxSetResourceString(@cxSGridSortColumnDesc, 'Сортировка от Я до А');
  cxSetResourceString(@cxSGridClearSorting, 'Отменить сортировку');
  cxSetResourceString(@cxSGridGroupByThisField, 'Группировать по этому полю');
  cxSetResourceString(@cxSGridRemoveThisGroupItem, 'Убрать из группировки');
  cxSetResourceString(@cxSGridGroupByBox, 'Область группировки');
  cxSetResourceString(@cxSGridAlignmentSubMenu, 'Выравнивание');
  cxSetResourceString(@cxSGridAlignLeft, 'По левому краю');
  cxSetResourceString(@cxSGridAlignRight, 'По правому краю');
  cxSetResourceString(@cxSGridAlignCenter, 'По центру');
  cxSetResourceString(@cxSGridRemoveColumn, 'Удалить поле');
  cxSetResourceString(@cxSGridFieldChooser, 'Выбор полей');
  cxSetResourceString(@cxSGridBestFit, 'Подобрать ширину');
  cxSetResourceString(@cxSGridBestFitAllColumns, 'Подобрать ширину(все поля)');
  cxSetResourceString(@cxSGridShowFooter, 'Итоги');
  cxSetResourceString(@cxSGridShowGroupFooter, 'Итоги по группе');

  // Footer popup menu item captions

  cxSetResourceString(@cxSGridNoneMenuItem, 'Ничего');
  cxSetResourceString(@cxSGridSumMenuItem, 'Сумма');
  cxSetResourceString(@cxSGridMinMenuItem, 'Минимум');
  cxSetResourceString(@cxSGridMaxMenuItem, 'Максимум');
  cxSetResourceString(@cxSGridCountMenuItem, 'Кол-во');
  cxSetResourceString(@cxSGridAvgMenuItem, 'Среднее');

  // Group row popup menu item captions

  cxSetResourceString(@cxSGridSortByGroupValues, 'Сортировать по значению группы');
  cxSetResourceString(@cxSGridSortBySummaryCaption, 'Сортировать по итогам группы:');
  cxSetResourceString(@cxSGridSortBySummary, '%s для %s');

(*--------------- FILTER DIALOG -----------------------------------------------
  // cxFilterBoolOperator
  cxSFilterBoolOperatorAnd = 'AND';        // all
  cxSFilterBoolOperatorOr = 'OR';          // any
  cxSFilterBoolOperatorNotAnd = 'NOT AND'; // not all
  cxSFilterBoolOperatorNotOr = 'NOT OR';   // not any
  //
  cxSFilterRootButtonCaption = 'Filter';
  cxSFilterAddCondition = 'Add &Condition';
  cxSFilterAddGroup = 'Add &Group';
  cxSFilterRemoveRow = '&Remove Row';
  cxSFilterClearAll = 'Clear &All';
  cxSFilterFooterAddCondition = 'press the button to add a new condition';

  cxSFilterGroupCaption = 'applies to the following conditions';
  cxSFilterRootGroupCaption = '<root>';
  cxSFilterControlNullString = '<empty>';

  cxSFilterErrorBuilding = 'Can''t build filter from source';

  //FilterDialog
  cxSFilterDialogCaption = 'Custom Filter';
  cxSFilterDialogInvalidValue = 'Invalid value';
  cxSFilterDialogUse = 'Use';
  cxSFilterDialogSingleCharacter = 'to represent any single character';
  cxSFilterDialogCharactersSeries = 'to represent any series of characters';
  cxSFilterDialogOperationAnd = 'AND';
  cxSFilterDialogOperationOr = 'OR';
  cxSFilterDialogRows = 'Show rows where:';

  // FilterControlDialog
  cxSFilterControlDialogCaption = 'Filter builder';
  cxSFilterControlDialogNewFile = 'untitled.flt';
  cxSFilterControlDialogOpenDialogCaption = 'Open an existing filter';
  cxSFilterControlDialogSaveDialogCaption = 'Save the active filter to file';
  cxSFilterControlDialogActionSaveCaption = '&Save As...';
  cxSFilterControlDialogActionOpenCaption = '&Open...';
  cxSFilterControlDialogActionApplyCaption = '&Apply';
  cxSFilterControlDialogActionOkCaption = 'OK';
  cxSFilterControlDialogActionCancelCaption = 'Cancel';
  cxSFilterControlDialogFileExt = 'flt';
  cxSFilterControlDialogFileFilter = 'Filters (*.flt)|*.flt';

-----------------------------------------------------------------------------*)

  cxSetResourceString(@cxSFilterBoolOperatorAnd,  'И');
  cxSetResourceString(@cxSFilterBoolOperatorOr, 'ИЛИ');
  cxSetResourceString(@cxSFilterBoolOperatorNotAnd,  'НЕ И');
  cxSetResourceString(@cxSFilterBoolOperatorNotOr, 'НЕ ИЛИ');

  cxSetResourceString(@cxSFilterRootButtonCaption, 'Фильтр');
  cxSetResourceString(@cxSFilterAddCondition, 'Добавить условие');
  cxSetResourceString(@cxSFilterAddGroup, 'Добавить группу');
  cxSetResourceString(@cxSFilterRemoveRow, 'Удалить строку');
  cxSetResourceString(@cxSFilterClearAll, 'Очистить все');
  cxSetResourceString(@cxSFilterFooterAddCondition, 'нажми кнопку для добавления условия');

  cxSetResourceString(@cxSFilterGroupCaption, 'применить к следующему условию');
  cxSetResourceString(@cxSFilterRootGroupCaption, '<корень>');
  cxSetResourceString(@cxSFilterControlNullString, '<пусто>');

  cxSetResourceString(@cxSFilterErrorBuilding, 'Can''t build filter from source');

  //FilterDialog
  cxSetResourceString(@cxSFilterDialogCaption, 'Настройка фильтра');
  cxSetResourceString(@cxSFilterDialogInvalidValue, 'Ошибочное значение');
  cxSetResourceString(@cxSFilterDialogUse, 'Использовать');
  cxSetResourceString(@cxSFilterDialogSingleCharacter, 'для подстановки любого одиночного символа');
  cxSetResourceString(@cxSFilterDialogCharactersSeries, 'для подстановки любых символов');
  cxSetResourceString(@cxSFilterDialogOperationAnd, 'И');
  cxSetResourceString(@cxSFilterDialogOperationOr, 'ИЛИ');
  cxSetResourceString(@cxSFilterDialogRows, 'Отобразить строки где:');


  cxSetResourceString(@cxSFilterControlDialogCaption,'Построитель фильтров');
  cxSetResourceString(@cxSFilterControlDialogNewFile,  'untitled.flt');
  cxSetResourceString(@cxSFilterControlDialogOpenDialogCaption, 'Открыть сохраненный фильтр');
  cxSetResourceString(@cxSFilterControlDialogSaveDialogCaption,'Сохранить текущий фильтр в файл');
  cxSetResourceString(@cxSFilterControlDialogActionSaveCaption, '&Сохранить как...');
  cxSetResourceString(@cxSFilterControlDialogActionOpenCaption, '&Открыть...');
  cxSetResourceString(@cxSFilterControlDialogActionApplyCaption, '&Применить');
  cxSetResourceString(@cxSFilterControlDialogActionOkCaption, 'OK');
  cxSetResourceString(@cxSFilterControlDialogActionCancelCaption, 'Отмена');
  cxSetResourceString(@cxSFilterControlDialogFileExt, 'flt');
  cxSetResourceString(@cxSFilterControlDialogFileFilter, 'Filters (*.flt)|*.flt');

(*------------------------- FILTER -------------------------------------------
  // base operators
  cxSFilterOperatorEqual = 'equals';
  cxSFilterOperatorNotEqual = 'does not equal';
  cxSFilterOperatorLess = 'is less than';
  cxSFilterOperatorLessEqual = 'is less than or equal to';
  cxSFilterOperatorGreater = 'is greater than';
  cxSFilterOperatorGreaterEqual = 'is greater than or equal to';
  cxSFilterOperatorLike = 'like';
  cxSFilterOperatorNotLike = 'not like';
  cxSFilterOperatorBetween = 'between';
  cxSFilterOperatorNotBetween = 'not between';
  cxSFilterOperatorInList = 'in';
  cxSFilterOperatorNotInList = 'not in';

  cxSFilterOperatorYesterday = 'is yesterday';
  cxSFilterOperatorToday = 'is today';
  cxSFilterOperatorTomorrow = 'is tomorrow';

  cxSFilterOperatorLast7Days = 'is last 7 days';
  cxSFilterOperatorLastWeek = 'is last week';
  cxSFilterOperatorLast14Days = 'is last 14 days';
  cxSFilterOperatorLastTwoWeeks = 'is last two weeks';
  cxSFilterOperatorLast30Days = 'is last 30 days';
  cxSFilterOperatorLastMonth = 'is last month';
  cxSFilterOperatorLastYear = 'is last year';
  cxSFilterOperatorPast = 'is past';

  cxSFilterOperatorThisWeek = 'is this week';
  cxSFilterOperatorThisMonth = 'is this month';
  cxSFilterOperatorThisYear = 'is this year';

  cxSFilterOperatorNext7Days = 'is next 7 days';
  cxSFilterOperatorNextWeek = 'is next week';
  cxSFilterOperatorNext14Days = 'is next 14 days';
  cxSFilterOperatorNextTwoWeeks = 'is next two weeks';
  cxSFilterOperatorNext30Days = 'is next 30 days';
  cxSFilterOperatorNextMonth = 'is next month';
  cxSFilterOperatorNextYear = 'is next year';
  cxSFilterOperatorFuture = 'is future';

  cxSFilterAndCaption = 'and';
  cxSFilterOrCaption = 'or';
  cxSFilterNotCaption = 'not';
  cxSFilterBlankCaption = 'blank';

  // derived
  cxSFilterOperatorIsNull = 'is blank';
  cxSFilterOperatorIsNotNull = 'is not blank';
  cxSFilterOperatorBeginsWith = 'begins with';
  cxSFilterOperatorDoesNotBeginWith = 'does not begin with';
  cxSFilterOperatorEndsWith = 'ends with';
  cxSFilterOperatorDoesNotEndWith = 'does not end with';
  cxSFilterOperatorContains = 'contains';
  cxSFilterOperatorDoesNotContain = 'does not contain';
  // filter listbox's values
  cxSFilterBoxAllCaption = '(All)';
  cxSFilterBoxCustomCaption = '(Custom...)';
  cxSFilterBoxBlanksCaption = '(Blanks)';
  cxSFilterBoxNonBlanksCaption = '(NonBlanks)';
-----------------------------------------------------------------------------*)

  cxSetResourceString(@cxSFilterOperatorEqual, 'равно');
  cxSetResourceString(@cxSFilterOperatorNotEqual, 'не равно');
  cxSetResourceString(@cxSFilterOperatorLess, 'мешьше чем');
  cxSetResourceString(@cxSFilterOperatorLessEqual, 'мешьше или равно чем');
  cxSetResourceString(@cxSFilterOperatorGreater, 'больше чем');
  cxSetResourceString(@cxSFilterOperatorGreaterEqual, 'больше или равно чем');
  cxSetResourceString(@cxSFilterOperatorLike, 'содержит');
  cxSetResourceString(@cxSFilterOperatorNotLike, 'не содержит');
  cxSetResourceString(@cxSFilterOperatorBetween, 'between');
  cxSetResourceString(@cxSFilterOperatorNotBetween, 'not between');
  cxSetResourceString(@cxSFilterOperatorInList, 'in');
  cxSetResourceString(@cxSFilterOperatorNotInList, 'not in');



  cxSetResourceString(@cxSFilterAndCaption, 'и');
  cxSetResourceString(@cxSFilterOrCaption, 'или');
  cxSetResourceString(@cxSFilterNotCaption, 'не');
  cxSetResourceString(@cxSFilterBlankCaption, 'пусто');

  cxSetResourceString(@cxSFilterOperatorIsNull, 'пусто');
  cxSetResourceString(@cxSFilterOperatorIsNotNull, 'не пусто');
  cxSetResourceString(@cxSFilterOperatorBeginsWith, 'начинается с');
  cxSetResourceString(@cxSFilterOperatorDoesNotBeginWith, 'не начинается с');
  cxSetResourceString(@cxSFilterOperatorEndsWith, 'заканчивается на');
  cxSetResourceString(@cxSFilterOperatorDoesNotEndWith, 'не заканчивается на');
  cxSetResourceString(@cxSFilterOperatorContains, 'содержит');
  cxSetResourceString(@cxSFilterOperatorDoesNotContain, 'не содержит');

  cxSetResourceString(@cxSFilterBoxAllCaption, '(Все)');
  cxSetResourceString(@cxSFilterBoxCustomCaption, '(Настроить...)');
  cxSetResourceString(@cxSFilterBoxBlanksCaption, '(Пусто)');
  cxSetResourceString(@cxSFilterBoxNonBlanksCaption, '(Не пусто)');


end;

end.
