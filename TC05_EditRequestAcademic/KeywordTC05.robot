*** Settings ***
Library    SeleniumLibrary
Resource    TC05_EditRequestAcademic.robot


*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC05-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window


Run EditRequestAcademic
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    11
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}
    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Go To Login Page
    ...    AND    Login As Member
    ...    AND    Go To Edit Request Page    ${row}
    ...    AND    Fill Request Form    ${row}
    ...    AND    Fill Start Date    ${row}
    ...    AND    Fill End Date    ${row}
    ...    AND    Submit Request Form
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate And Write Result    ${row}
    ...    AND    Logout
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับสมาชิกผู้ยื่นคำร้องขอ')] 

Login As Member
    Input Text    //input[@id='uname']    Sch1@hotmail.com
    Input Text    //input[@id='pwd']   Schpwd_.  
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT 

Go To Edit Request Page
    [Arguments]    ${i}
    Click Element    //div[@class='side-link'][3]
    Click Element    //tbody/tr[144]/td[8]/a[1]/img[1]
    Sleep    2

Fill Request Form
    [Arguments]    ${i}
    ${SCHOOLNAME}=    Read Excel Cell    ${i}    2
    ${SCHOOLNAME}=    Evaluate    '' if $SCHOOLNAME in ['None', '', None] else $SCHOOLNAME
    Input Text    css:#requestSchool    ${SCHOOLNAME}

    ${FN_LN}=    Read Excel Cell    ${i}    3
    ${FN_LN}=    Evaluate    '' if $FN_LN in ['None', '', None] else $FN_LN
    Input Text    css:#requestName    ${FN_LN}

    ${RQDetail}=    Read Excel Cell    ${i}    4
    ${RQDetail}=    Evaluate    '' if $RQDetail in ['None', '', None] else $RQDetail
    Input Text    css:#requestDetail    ${RQDetail}


Fill Start Date 
    [Arguments]    ${i}
    ${STDATE}=    Read Excel Cell    ${i}    5
    ${conv_result}=    Run Keyword And Ignore Error    Convert Date    ${STDATE}    result_format=%m-%d-%Y
    ${status}=    Set Variable    ${conv_result[0]}
    ${STDATE_CONVERTED}=    Set Variable    ${conv_result[1]}

    Input Text    css:#startDate    ${STDATE_CONVERTED}
    Log To Console    วันเริ่ม: ${STDATE_CONVERTED}
    Sleep    2
    

Fill End Date 
    [Arguments]    ${i}
    ${ENDDATE}=    Read Excel Cell    ${i}    6
    ${conv_result}=    Run Keyword And Ignore Error    Convert Date    ${ENDDATE}    result_format=%m-%d-%Y
    ${status}=    Set Variable    ${conv_result[0]}
    ${ENDDATE_CONVERTED}=    Set Variable    ${conv_result[1]}
    Input Text    css:#endDate    ${ENDDATE_CONVERTED}
    Log To Console    วันสิ้นสุด: ${ENDDATE_CONVERTED}
    Sleep    2

    
Submit Request Form
    Click Button    //button[@value='save']
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
        Capture Page Screenshot    TC05_EditRequestAcademic/Screenshots_AlertNotFound/${i}_AlertNotFound.png
        Sleep    2
    END
    Run Keyword And Ignore Error    Click Element    //body/form[1]/div[1]/div[1]/div[2]/a[1]
    Set Test Variable    ${ActualMessage}
    Sleep    2

Validate And Write Result
    [Arguments]    ${i}
    ${ExpectedResult}    Read Excel Cell    ${i}    7
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${i}    9    ${ActualMessage}
    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF   ${compare_result}
        Write Excel Cell    ${i}    10    PASS
        Capture Page Screenshot    TC05_EditRequestAcademic/Screenshots_Pass/${i}_${ActualMessage}.png
    ELSE
        Write Excel Cell    ${i}    10    FAIL 
        Capture Page Screenshot    TC05_EditRequestAcademic/Screenshots_Fail/${i}_${ActualMessage}.png
    END
    Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}



Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    13    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    13    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}


Logout
    Run Keyword And Ignore Error    Click Element    //a[contains(text(),'ออกจากระบบ')]