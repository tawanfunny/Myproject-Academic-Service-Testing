*** Settings ***
Library    SeleniumLibrary
Resource    TC04_CancelService.robot


*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC04-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับสมาชิกผู้ยื่นคำร้องขอ')] 

Login As Member
    Input Text    //input[@id='uname']    SchAssumptiona@gmail.com
    Input Text    //input[@id='pwd']   Schpwd_.  
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT 

Go To Cancel Request Page
    Click Element    //body/form[1]/div[1]/div[1]/div[3]/a[1]

Run CancelService
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    9
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}
    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords  
    ...    Setup Speed 
    ...    AND    Button Cancel Request Page    ${row}
    ...    AND    Fill Cancel Request Form    ${row}
    ...    AND    Submit Cancel Form
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate And Write Result    ${row}
    ...    AND    Go To Page Cancel
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}


Button Cancel Request Page
    [Arguments]    ${i}
    Click Element    //tbody/tr[${i}-1]/td[9]/a[1]
    Sleep    2

Fill Cancel Request Form
    [Arguments]    ${i}
    ${SCHOOLNAME}    Read Excel Cell    ${i}    2
    ${SCHOOLNAME}=    Evaluate    '' if $SCHOOLNAME in ['None', '', None] else $SCHOOLNAME
    Input Text    css:#cancelSchool    ${SCHOOLNAME}

    ${FN_LN}    Read Excel Cell    ${i}    3
    ${FN_LN}=    Evaluate    '' if $FN_LN in ['None', '', None] else $FN_LN
    Input Text    css:#cancelName    ${FN_LN}

    ${RQDetail}    Read Excel Cell    ${i}    4
    ${RQDetail}=    Evaluate    '' if $RQDetail in ['None', '', None] else $RQDetail
    Input Text    css:#cancelDetail    ${RQDetail}

    
Submit Cancel Form
    Click Element    //button[contains(text(),'ส่งคำขอยกเลิกคำร้อง')]
    Sleep    2s

Handle Submission Result
        [Arguments]    ${i}
        ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
        Log To Console    Alert Status: ${alert_result[0]}
        Log To Console    Alert Text: ${alert_result[1]}

        IF    '${alert_result[0]}' == 'PASS'
            ${ActualMessage}=    Set Variable    ${alert_result[1]}
            
        ELSE
            ${ActualMessage}=    Set Variable    Alert not found
            Sleep    2
            Capture Page Screenshot    TC04_CancelService/Screenshots_AlertNotFound/${i}_AlertNotFound.png
            
        END
        Run Keyword And Ignore Error    Click Element    //body/form[1]/div[1]/div[1]/div[3]/a[1]
        Set Test Variable    ${ActualMessage}
        Sleep    2

Validate And Write Result
        [Arguments]    ${i}
    
        ${ExpectedResult}    Read Excel Cell    ${i}    5
        ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
        ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

        Log To Console    Expected Result: ${ExpectedResult}
        Log To Console    Actual Message: ${ActualMessage}

        Write Excel Cell    ${i}    7    ${ActualMessage}
        ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
        IF    ${compare_result}
            Write Excel Cell    ${i}    8    PASS
            Capture Page Screenshot    TC04_CancelService/Screenshots_Pass/${i}_${ActualMessage}.png
        ELSE
            Write Excel Cell    ${i}    8    FAIL
            Capture Page Screenshot    TC04_CancelService/Screenshots_Fail/${i}_${ActualMessage}.png
        END
        
        Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}



Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    11    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    11    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}



Go To Page Cancel   
    Click Element    //body/div[1]/div[1]/div[3]/a[1]
    Sleep    1s
