*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    OperatingSystem
Library    DatabaseLibrary
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database




*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC10_AddProposal/10_AddProposalToEdit.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    144
${cols}    25

*** Test Cases ***
TC10: 10_AddProposalToEdit
    Go To Academic_Services    ${datatable}    
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${ALLOW}=    Read Excel Cell    ${i}    23
        ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
        Log To Console    Row ${i} - Allow: ${ALLOW}

        Run Keyword If    '${ALLOW}' == 'Y'
        ...    Run Keywords
        ...    Clear AddProposal Data In DB    ${i}
        ...    AND    Run AddProposalToEdit    ${i}

        Run Keyword If    '${ALLOW}' != 'Y'
        ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document


*** Keywords ***
Clear AddProposal Data In DB
    [Arguments]    ${i}
    ${STDID}    Read Excel Cell    ${i}    2
    ${STDID}=    Evaluate    '' if $STDID in ['None', '', None] else $STDID
    Log To Console    Trying to delete proposal with studentId: ${STDID}
    ${query}=    Set Variable    DELETE FROM `db_academic_services`.`proposal` WHERE studentId = '${STDID}';
    Execute Sql String    ${query}


Go To Academic_Services
    [Arguments]    ${i}
    Open Excel Document    ${datatable}    addToEdit
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.1

Run AddProposalToEdit
    [Arguments]    ${i}
    ${ALLOW}=    Read Excel Cell    ${i}    23
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${i} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Go To LoginStudent    ${i}
    ...    AND    Go To AddProposal    
    ...    AND    Fill Proposal Form    ${i}
    ...    AND    Handle Submission Result    ${i}
    ...    AND    Validate And Write Result    ${i}
    
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}

Go To LoginStudent
    [Arguments]    ${i}
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')] 

    ${STDID}    Read Excel Cell    ${i}    2
    ${STDID}=    Evaluate    '' if $STDID in ['None', '', None] else $STDID
    Input Text    css:#stuname    ${STDID}

    ${STDPWD}    Read Excel Cell    ${i}    3
    ${STDPWD}=    Evaluate    '' if $STDPWD in ['None', '', None] else ${STDPWD}
    Input Text    css:#stupwd    ${STDPWD}

    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT

Go To AddProposal
    Click Element    //body/div[1]/div[1]/div[3]/a[1]
    Click Element    //a[contains(text(),'จัดส่งรายละเอียดโครงการ')] 

Fill Proposal Form
    [Arguments]    ${i}
    ${ProjectTitle}    Read Excel Cell    ${i}    4
        ${ProjectTitle}=    Evaluate    '' if $ProjectTitle in ['None', '', None] else $ProjectTitle
        Input Text    css:#projectTitle    ${ProjectTitle}
        

        ${Logical}    Read Excel Cell    ${i}    5
        ${Logical}=    Evaluate    '' if $Logical in ['None', '', None] else $Logical
        Input Text    //div[@id='logical']//div[@class='ql-editor ql-blank']    ${Logical}
        

        ${Objective}    Read Excel Cell    ${i}    6
        ${Objective}=    Evaluate    '' if $Objective in ['None', '', None] else $Objective
        Input Text    //div[@id='objective']//div[@class='ql-editor ql-blank']    ${Objective}

        ${Target}    Read Excel Cell    ${i}    7
        ${Target}=    Evaluate    '' if $Target in ['None', '', None] else $Target
        Input Text    css:#target    ${Target} 

        ${HowToProceed}    Read Excel Cell    ${i}    8
        ${HowToProceed}=    Evaluate    '' if $HowToProceed in ['None', '', None] else $HowToProceed
        Input Text    //div[@id='detailActivity']//div[@class='ql-editor ql-blank']    ${HowToProceed}
        

        ${DurationOfOperation}    Read Excel Cell    ${i}    9
        ${DurationOfOperation}=    Evaluate    '' if $DurationOfOperation in ['None', '', None] else $DurationOfOperation
        Input Text    //div[@id='projectPeriod']//div[@class='ql-editor ql-blank']    ${DurationOfOperation}

        ${Budget}    Read Excel Cell    ${i}    10
        ${Budget}=    Evaluate    '' if $Budget in ['None', '', None] else $Budget
        Input Text    //div[@id='budget']//div[@class='ql-editor ql-blank']    ${Budget}

        ${StudentId}    Read Excel Cell    ${i}    11
        ${StudentId}=    Evaluate    '' if $StudentId in ['None', '', None] else $StudentId
        Input Text    //input[@name='memberStudentId[]']    ${StudentId}

        ${StudentFName}    Read Excel Cell    ${i}    12
        ${StudentFName}=    Evaluate    '' if $StudentFName in ['None', '', None] else $StudentFName
        Input Text    //input[@name='memberFName[]']    ${StudentFName}

        ${StudentLName}    Read Excel Cell    ${i}    13
        ${StudentLName}=    Evaluate    '' if $StudentLName in ['None', '', None] else $StudentLName
        Input Text    //input[@name='memberLName[]']    ${StudentLName}

        ${Position}    Read Excel Cell    ${i}    14
        ${Position}=    Evaluate    '' if $Position in ['None', '', None] else $Position
        Input Text    //input[@name='memberPosition[]']    ${Position}

        ${Location}    Read Excel Cell    ${i}    15
        ${Location}=    Evaluate    '' if $Location in ['None', '', None] else $Location
        Input Text    css:#location    ${Location}

        ${RiskAndSolve}    Read Excel Cell    ${i}    16
        ${RiskAndSolve}=    Evaluate    '' if $RiskAndSolve in ['None', '', None] else $RiskAndSolve
        Input Text    //div[@id='riskAndSolve']//div[@class='ql-editor ql-blank']    ${RiskAndSolve}

        ${EvaluationCriteria}    Read Excel Cell    ${i}    17
        ${EvaluationCriteria}=    Evaluate    '' if $EvaluationCriteria in ['None', '', None] else $EvaluationCriteria
        Input Text    //div[@id='evaluation']//div[@class='ql-editor ql-blank']    ${EvaluationCriteria}

        ${ProjectAdvisor}    Read Excel Cell    ${i}    18
        ${ProjectAdvisor}=    Evaluate    '' if $ProjectAdvisor in ['None', '', None] else $ProjectAdvisor
        Input Text    //input[@name='projectAdvisor']    ${ProjectAdvisor}

        Click Element    //input[@type='submit']
        sleep    2s

Handle Submission Result
    [Arguments]    ${i}

    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}
    
    Set Test Variable    ${alert_result}
    IF  '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
        Go To    ${URL}
    ELSE
        ${ActualMessage}=    Set Variable    Alert not found 
        sleep    2
        Go To    ${URL}
    END
    Set Test Variable    ${ActualMessage}
    Sleep    2

Validate And Write Result
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    19
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${i}    21    ${ActualMessage}
    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    22    PASS
        Go To    ${URL}
    ELSE
        Write Excel Cell    ${i}    22    FAIL
        Go To    ${URL}
    END
    
   

     
