// import 'package:flutter/cupertino.dart';
// import 'package:googleapis/connectors/v1.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:provider/provider.dart';
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
//
// class PushNotificationServices{
//
//   static Future<String> getAccessTakens()async{
//     final serviceAccountJson={
//       "type": "service_account",
//       "project_id": "graduation-project-2024",
//       "private_key_id": "e1d0f1ea8e569bfff36b2dbc8a1373b5b1f8d227",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCj80hHcThixUkp\nT5pd1S9154mT7ITrq3Oqpdao9TDMUwI2SLT0m2YINcf+zZY4lHCpPu+uavMK9uyn\nc6aA0VZbM35OlNSLpkSo/wMxYIuBveVbliif68WuzYreN1k4FazETYKXx2v4keJc\nwKYIK24VWceIOXKHs4rRBP3BTUsGRPgdiTlbML28Leh/d6wpOZ07KMDOzTmfRe36\n0HvfjHvnVJ9obPF/b8Q7xBYIoUpSCSVdtXWALzq5WyoedrYMgLgn4MA5NP3fUMGx\n5gQysMQFs5N1CS1sucNI5aG63CJGnytrkdOCqHNAAIax/relgmhALByMuVyTjEtY\nPfubK0yfAgMBAAECggEAHCouiAtktt8SdvTUXXtCmHwqr81JdlzxVWcA7eyVMfyu\nnBm4cG8Dw7RNg7HYtSaXBhQoQ6vezcrmk8uz1lxf+/HoKGK78rOhBvEsIL7nqGWx\ncZ7lordzsdhgm1Uh0Bc1I1H3ddCN9VlGbE2yGCQx2JwgQYAw8yv+VHMJjrwS/+Px\n3d7BpG7h/FRxkfRErOOoeg5fENd1AFNOAgdJNyAFywz7TWYc/n/i9HGBJtaZ3gxN\nqOoetGUS9oeOUdX5IXppAdlD0cU7z2LyensH0W61aWD3SnBpv8zQGJfcKlPqVe6n\nUydinl9Dd3jEkEKNgpeedFYV1e/YfcgazOmKsHyqXQKBgQDRYFJI4g9C2PV6dygc\n4jAO+L1wYXJNeUSqkayEluKDCSrKkqdFySPBzcr4EwgT6/8faS7Xlc9ljYM0pCHY\nOoums3sp++fhZoAA2KZVLZiFj22T/drrPrai4wCvrYXYdhBtY+wEDQB3nf9ve5bg\n4wpcOceb/weqxAiJQ2tJEtHo/QKBgQDIdWpW014ReqAhZSTU0bjzgjFCpJMli4lD\n7RWocMfItM6zBprPtFJGYxf+W0pFhCb50b27YlXu8V8VyqME39l5uhtDPlt64+sw\nk0VuABd2i1IRcUCx7xrm4ikZER8E3TBiMabuA51SgsSMh9FWvUJH8Q09X1lkR/3l\nPAcPwmF8ywKBgCjs1OieFzGPytu3MsYCiDZE9HJk+bye+YcFll0MSRYn0o9p/vwr\nBqw5F3VJ8whB1spC+v70r2dAM+c0NdFYEDfzWR2puXdbW6XOsyRvFyL0GA0XT5Uv\n2u8Xw+iS2FipKyjWoSlhiTfYUDdwRtuKRVoliRi6zrrYOnrqDKxp21HZAoGAVPoh\nWClGKVa4Zy+/S1CUfPXl+ABYOIRMbjUlB0C4EIdFUHMuUXp5nkkHtNXySEHbW+/j\n5HmtQBumWVCLhtd2E7onMHxQv2m7G95ygk0bpS8uXSKLcGKSHuokzfGKGr/BcP7n\nauKxYHb65y/0ODcG0ASJvkibVn2GThUCUVXvib0CgYBAYzd0pexGICW1fys1aEi/\n6o4QNP14GpYGOoBaxIiTG9J6aZJhfxJCVaI7S00LLrP+DlnwC0Jo+ChKVyGFfqNP\nvbryrNahRkKXyqiKOajgK6sUHWYSxDCbHWr4LfD3leAgrBb6dUYtk/z45Tu9lbQN\nkYElBgJ0UG9rzNuNxBtA3g==\n-----END PRIVATE KEY-----\n",
//       "client_email": "graduation-project2024@graduation-project-2024.iam.gserviceaccount.com",
//       "client_id": "107835126419070980525",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/graduation-project2024%40graduation-project-2024.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };
//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging"
//     ];
//     http.Client client = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//     );
//     auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//       client
//     );
//     client.close();
//
//     return credentials.accessToken.data;
//
//   }
//
//   // static sendNotificationToSelectDriver(String deviceToken, BuildContext context, String tripID)async{
//   //
//   //   String dropOffDestinationAddress = Provider.of<AppInfo>(context,listen:false).dropOffLocation!.placeName.toString();
//   //
//   //   final String serverKey = await getAccessTakens();
//   //
//   //   String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/graduation-project-2024/messages:send';
//   //
//   //   final Map<String,dynamic> message = {
//   //     'message':{
//   //       'token':deviceToken,
//   //       'notification':{
//   //         'title': "",
//   //         'body': ""
//   //       }
//   //     }
//   //   };
//   // }
//
//     static SendNotificationToUser = (
//       String deviceToken,
//       BuildContext cotext,
//       String tripId,
//       String messageSender,
//       String messageBodt,
//   ) async{
//     final String serverAccessTokenKey = await getAccessTakens();
//     final String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/graduation-project-2024/messages:send';
//     final Map<String,dynamic> message = {
//       'message':{
//         'token':deviceToken,
//         'notification':{
//           'title': messageSender,

//           'body': messageBodt
//         },
//         'data': tripId,
//       }
//     };
// };
// }