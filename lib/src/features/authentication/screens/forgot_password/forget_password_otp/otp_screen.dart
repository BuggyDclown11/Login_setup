import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_setup/src/constants/sizes.dart';
import 'package:login_setup/src/constants/text_strings.dart';
import 'package:login_setup/src/features/authentication/controllers/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var otp;
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(tDefaultSize),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tOtpTitle,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, fontSize: 80.0),
          ),
          Text(
            tOtpSubTitle.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 40.0,
          ),
          Text(
            "$tOtpmessage 123@gmail.com",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20.0,
          ),
          OtpTextField(
              numberOfFields: 6,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              onSubmit: (code) {
                otp = code;
                OTPController.instance.verifyOTP(otp);
              }
              // {
              //   print("OTP is => $code");
              // },
              ),
          SizedBox(
            height: 20.0,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  OTPController.instance.verifyOTP(otp);
                },
                child: Text("Next")),
          )
        ],
      ),
    ));
  }
}
