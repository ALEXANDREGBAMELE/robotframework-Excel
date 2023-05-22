*** Setting ***
Documentation     Transferer les donnees dans une bd puis un fichier excel
Suite Setup       Connect To Database     psycopg2   ${dbname}   ${dbusername}   ${dbpassword}   ${dbhost}   ${dbport}
Suite Teardown    Disconnect From Database
Library           ExcelLibrary
Library           DatabaseLibrary
Library           RPA.Email.ImapSmtp


*** Variables ***

${chemin}       ${CURDIR}${/}\\donneecaisse.xlsx
${filename}     Feuil1
${resultDB}

${dbname}       dbtestrobot
${dbusername}   postgres
${dbpassword}   root
${dbhost}       localhost
${dbport}       5432
${tblname}      tbl_rapport_journalier

*** Test Cases ***
Rapport jounalier caisse
    ${nom_magasin}                  Lire Excel    ${chemin}     ${filename}      2   3
    ${nom_responsable}              Lire Excel    ${chemin}     ${filename}      3   3
    ${email_responsable}            Lire Excel    ${chemin}     ${filename}      4   3
    ${jounee}                       Lire Excel    ${chemin}     ${filename}      5   3
    Log    ${jounee} 
    ${carte_bancaire}               Lire Excel    ${chemin}     ${filename}      11   4
    ${especes}                      Lire Excel    ${chemin}     ${filename}      12   4
    ${ticket_restaurant}            Lire Excel    ${chemin}     ${filename}      13   4
    ${prelevement}                  Lire Excel    ${chemin}     ${filename}      15   4
    ${apportmonnaie}                Lire Excel    ${chemin}     ${filename}      16   4

    Insertion                       ${nom_magasin}    ${nom_responsable}    ${email_responsable}    ${jounee}    ${carte_bancaire}   ${especes}    ${ticket_restaurant}   ${prelevement}   ${apportmonnaie}
    ${solde}                        Verification                    ${carte_bancaire}     ${especes}      ${ticket_restaurant}        ${prelevement}      ${apportmonnaie}
    
*** Keywords ***

Lire Excel
    [Arguments]     ${NomChemin}       ${NomFichier}     ${Ligne}     ${Colonne}
    Open Excel Document                ${NomChemin}    1
    Get Sheet                          ${NomFichier}           
    ${result}                          Read Excel Cell       ${Ligne}        ${Colonne} 
    [Return]                           ${result} 
    Close Current Excel Document

Insertion
    [Arguments]     ${nom_magasin}    ${nom_responsable}    ${email_responsable}    ${jounee}    ${carte_bancaire}   ${especes}    ${ticket_restaurant}   ${prelevement}   ${apportmonnaie}
    ${query}    Catenate       INSERT INTO  tbl_rapport_journalier (nom_magasin,nom_responsable, email_responsable, jounee, carte_bancaire, especes, ticket_restaurant, prelevement, apportmonnaie ) VALUES ('${nom_magasin}','${nom_responsable}','${email_responsable}','${jounee}','${carte_bancaire}','${especes}','${ticket_restaurant}','${prelevement}','${apportmonnaie}')
    #${Insertion}    Query       insert into tbl_rapport_journalier(nom_magasin,nom_responsable,email_responsable,jounee,carte_bancaire,especes,ticket_restaurant,prelevement,apportmonnaie) values('SOCOSE','KONATE DISTRIBUTION','konatetekernel@gmail.com','2014/06/12',2300,4500,6500,76323,700);
    Execute Sql String    ${query}
Verification
    [Arguments]                             ${carte_bancaire}     ${especes}      ${ticket_restaurant}        ${prelevement}      ${apportmonnaie}
    ${montant_total}    Evaluate            ${carte_bancaire}+${especes}+${ticket_restaurant}
    ${solde}            Evaluate            ${prelevement} - ${apportmonnaie}
    ${solde_valid}      Run Keyword If      '${montant_total}'=='${solde}'    Set Variable    ${True}     ELSE    Set Variable    ${False}
    [Return]            ${solde_valid}