*** Settings ***
Library    SeleniumLibrary
Resource    TC07_RegisterStudent.robot

*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2
Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC07-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    

Run Register_Student
    [Arguments]    ${i}
    ${ALLOW}=    Read Excel Cell    ${i}    12
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${i} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Go To RegisterStudent
    ...    AND    Fill Student Registration Form    ${i}
    ...    AND    Handle Submission Result    ${i}
    ...    AND    Validate And Write Result    ${i}
    ...    AND    Go To Home Page
    
        
 
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${i} due to Allow = ${ALLOW}

Go To RegisterStudent
    Click Element    //button[contains(text(),'สมัครสมาชิก')]
    Click Element    //a[contains(text(),'สมัครสมาชิกสำหรับนักศึกษา')]

Fill Student Registration Form
    [Arguments]    ${i}
    ${STDFName}=    Read Excel Cell    ${i}    2
    ${STDFName}=    Evaluate    '' if $STDFName in ['None', '', None] else $STDFName
    Input Text    css:#studentFName    ${STDFName}
    Log To Console    Student First Name: ${STDFName}

    ${STDLName}=    Read Excel Cell    ${i}    3
    ${STDLName}=    Evaluate    '' if $STDLName in ['None', '', None] else $STDLName
    Input Text    css:#studentLName    ${STDLName}
    Log To Console    Student Last Name: ${STDLName}

    ${STDEmail}=    Read Excel Cell    ${i}    4
    ${STDEmail}=    Evaluate    '' if $STDEmail in ['None', '', None] else $STDEmail
    Input Text    css:#studentEmail    ${STDEmail}
    Log To Console    Student Email: ${STDEmail}

    ${STDTel}=    Read Excel Cell    ${i}    5
    ${STDTel}=    Evaluate    '' if $STDTel in ['None', '', None] else $STDTel
    Input Text    css:#studentTel   ${STDTel}
    Log To Console    Student Telephone: ${STDTel}

    ${STDID}=    Read Excel Cell    ${i}    6
    ${STDID}=    Evaluate    '' if $STDID in ['None', '', None] else $STDID
    Input Text    css:#studentId   ${STDID}
    Log To Console    Student ID: ${STDID}

    ${STDPWD}=    Read Excel Cell    ${i}    7
    ${STDPWD}=    Evaluate    '' if $STDPWD in ['None', '', None] else $STDPWD
    Input Text    css:#studentPassword    ${STDPWD}
    Log To Console    Student Password: ${STDPWD}

    Click Element    //input[@type='submit']
    sleep    2s

Handle Submission Result
    [Arguments]    ${i}
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}

    Set Test Variable    ${alert_result}

    IF    '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
        Run Keyword And Ignore Error    Mouse Over    css:a.back-home-link:nth-child(8)
        Run Keyword And Ignore Error    Click Element    css:a.back-home-link:nth-child(8)
        sleep    2s

    ELSE
        ${ActualMessage}=    Set Variable    Alert not found
        Sleep    2
        Capture Page Screenshot   TC07_RegisterStudent/Screenshots_AlertNotFound/${i}_AlertNotFound.png
        Run Keyword And Ignore Error    Mouse Over    //body/div[1]/a[1]
        Run Keyword And Ignore Error    Click Element    //body/div[1]/a[1]
    END
    Set Test Variable    ${ActualMessage}
    Sleep    2


Validate And Write Result
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    8
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${i}    10    ${ActualMessage}

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    11    PASS
        Capture Page Screenshot    TC07_RegisterStudent/Screenshots_Pass/${i}_${ActualMessage}.png
    ELSE
        Write Excel Cell    ${i}    11    FAIL
        Capture Page Screenshot   TC07_RegisterStudent/Screenshots_Fail/${i}_${ActualMessage}.png
    END

    Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    14    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    14    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}


Go To Home Page
    Run Keyword And Ignore Error    Click Element    //body/div[1]/a[1]
    Sleep    2s
   



