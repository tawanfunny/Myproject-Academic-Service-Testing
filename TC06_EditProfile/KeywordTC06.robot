*** Settings ***
Library    SeleniumLibrary
Resource    TC06_EditProfile.robot

*** Keywords ***
Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC06-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับสมาชิกผู้ยื่นคำร้องขอ')] 

Login As Member
    Input Text    //input[@id='uname']    sch@gmail.com
    Input Text    //input[@id='pwd']   editpwd
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT 

Run EditFrofile
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    16
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Go To Edit Proflie
    ...    AND    Fill Edit School Registration Form    ${row}
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate And Write Result    ${row}
    ...    AND    Click To Edit Profile
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}


Go To Edit Proflie
    Click Element    //body/form[1]/div[1]/div[1]/div[1]/a[1]
    Sleep    2

Fill Edit School Registration Form
    [Arguments]    ${row}
    ${PF}=    Read Excel Cell    ${row}    2
    ${PF}=    Evaluate    '' if $PF in ['None', '', None] else $PF
    Run Keyword And Ignore Error    Select From List By Label    css:#prefix    ${PF}
    Log To Console    PF: ${PF}
    

    ${FN}=    Read Excel Cell    ${row}    3
    ${FN}=    Evaluate    '' if $FN in ['None', '', None] else $FN
    Input Text    css:#firstName    ${FN}
    Log To Console    FN: ${FN}

    ${LN}=    Read Excel Cell    ${row}    4
    ${LN}=    Evaluate    '' if $LN in ['None', '', None] else $LN
    Input Text    css:#lastName    ${LN}
    Log To Console    LN: ${LN}

    ${POSITION}=    Read Excel Cell    ${row}    5
    ${POSITION}=    Evaluate    '' if $POSITION in ['None', '', None] else $POSITION
    Input Text    css:#position    ${POSITION}
    Log To Console    POSITION: ${POSITION}

    ${SCHOOLNAME}=    Read Excel Cell    ${row}    6
    ${SCHOOLNAME}=    Evaluate    '' if $SCHOOLNAME in ['None', '', None] else $SCHOOLNAME
    Input Text    css:#schoolName    ${SCHOOLNAME}
    Log To Console    SCHOOLNAME: ${SCHOOLNAME}

    ${PHONE}=    Read Excel Cell    ${row}    7
    ${PHONE}=    Evaluate    '' if $PHONE in ['None', '', None] else $PHONE
    Input Text    css:#schoolTel    ${PHONE}
    Log To Console    PHONE: ${PHONE}

    ${ADDRESS}=    Read Excel Cell    ${row}    8
    ${ADDRESS}=    Evaluate    '' if $ADDRESS in ['None', '', None] else $ADDRESS
    Input Text    css:#schoolAddress    ${ADDRESS}
    Log To Console    ADDRESS: ${ADDRESS}

    ${PAGESCHOOL}=    Read Excel Cell    ${row}    9
    ${PAGESCHOOL}=    Evaluate    '' if $PAGESCHOOL in ['None', '', None] else $PAGESCHOOL
    Input Text    //input[@type='url']    ${PAGESCHOOL}
    Log To Console    PAGESCHOOL: ${PAGESCHOOL}

    ${EMAIL}=    Read Excel Cell    ${row}    10
    ${EMAIL}=    Evaluate    '' if $EMAIL in ['None', '', None] else $EMAIL
    Input Text    css:#schoolUsername    ${EMAIL}
    log To Console    EMAIL: ${EMAIL}

    ${PASSWORD}=    Read Excel Cell    ${row}    11
    ${PASSWORD}=    Evaluate    '' if $PASSWORD in ['None', '', None] else $PASSWORD
    Input Text    css:#schoolPassword    ${PASSWORD}
    log To Console    PASSWORD: ${PASSWORD}

    Click Button    //input[@type='submit']
    Sleep    2s

   
  

Handle Submission Result
    [Arguments]    ${row}
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}

    Set Test Variable    ${alert_result}
    IF    '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
    ELSE
        ${ActualMessage}=    Set Variable    Alert not found
        Sleep    2
        Capture Page Screenshot    Project_Test_AcademicService/TC06_EditProfile/Screenshots_AlertNotFound/${row}_AlertNotFound.png 
    END
    Run Keyword And Ignore Error    Mouse Over    css:a:nth-child(1)
    Run Keyword And Ignore Error    Click Element    css:a:nth-child(1)
    Set Test Variable    ${ActualMessage}
    Sleep    2

Validate And Write Result
    [Arguments]    ${row}
    ${ExpectedResult}=    Read Excel Cell    ${row}    12
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()
    
    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${row}    14    ${ActualMessage}

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${row}    15    PASS
        Capture Page Screenshot    Project_Test_AcademicService/TC06_EditProfile/Screenshots_Pass/${row}_${ActualMessage}.png
    ELSE
        Write Excel Cell    ${row}    15    FAIL
        Capture Page Screenshot    Project_Test_AcademicService/TC06_EditProfile/Screenshots_Fail/${row}_${ActualMessage}.png
    END
    Run Keyword    Write Suggestion Based On Comparison    ${row}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    18    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    18    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}

    
Click To Edit Profile
    Run Keyword And Ignore Error    Click Element    //body/div[1]/div[1]/div[1]/a[1]