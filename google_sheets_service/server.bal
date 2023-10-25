import ballerina/os;
import ballerina/http;
import ballerinax/googleapis.sheets as sheets;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

sheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);

final string sheetname = "completed-students";

service /students on new http:Listener(9092) {
    resource function post add(Student student) returns http:Ok|http:InternalServerError {
        if writeStudentDetails(student.ID, student.name, student.starredRepoCount) is error {
            return <http:InternalServerError> {
                body: "Error occurred while writing student details"
            };
        }
        return <http:Ok> {
            body: "Student details added successfully"
        };
    }
}

public function writeStudentDetails(string ID, string name, int staredRepoCount) returns error? {
    sheets:Spreadsheet spreadSheet = check spreadsheetClient->openSpreadsheetById("1fPGv-knr_hzkbtgaHvJpItyM8P8jFxmhtuNf3maa8sw");
    check spreadsheetClient->appendRowToSheet(spreadSheet.spreadsheetId, sheetname, [ID, name, staredRepoCount]);
}

public type Student record {|
    string ID;
    string name;
    int starredRepoCount;
|};
