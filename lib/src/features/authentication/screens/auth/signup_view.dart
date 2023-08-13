
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/signup_controller.dart';
import '../../models/user_model.dart';
import '../widgets/buttons/primary_button.dart';
import 'components/components.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final controller = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Text('Create Account', style: AppTypography.kBold24),
                SizedBox(height: AppSpacing.fiveVertical),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur',
                  style: AppTypography.kMedium14.copyWith(
                    color: AppColors.kGrey60,
                  ),
                ),
                SizedBox(height: AppSpacing.thirtyVertical),
                // FullName.
                AuthField(
                  title: 'Full Name',
                  hintText: 'Enter your name',
                  controller: controller.fullName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.fifteenVertical),
                // Email Field.
                AuthField(
                  title: 'E-mail',
                  hintText: 'Enter your email address',
                  controller: controller.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!value.isEmail) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.fifteenVertical),
                AuthField(
                  title: 'Phone number',
                  hintText: 'Enter your Phone Number',
                  controller: controller.phoneNo,
                  validator: (String? input) {
                    if (input!.isEmpty) {
                      return 'Enter  Phone number';
                    }
                    if (input.length < 13) {
                      return 'Please enter PhoneNo Starting with country code';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSpacing.thirtyVertical),

                // Password Field.
                AuthField(
                  title: 'Password',
                  hintText: 'Enter your password',
                  controller: controller.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 8) {
                      return 'Password should be at least 8 characters long';
                    }
                    return null;
                  },
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: AppSpacing.thirtyVertical),
                PrimaryButton(
                  onTap: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    } else {
                      final user = UserModel(
                          email: controller.email.text.trim(),
                          password: controller.password.text.trim(),
                          fullname: controller.fullName.text.trim(),
                          phoneNo: controller.phoneNo.text.trim());

                      SignUpController.instance.createUser(user);
                    }
                  },
                  text: 'Create An Account',
                ),
                SizedBox(height: AppSpacing.thirtyVertical),
                const TextWithDivider(),
                SizedBox(height: AppSpacing.twentyVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomSocialButton(
                      onTap: () {},
                      icon: AppAssets.kGoogle,
                    ),
                    CustomSocialButton(
                      onTap: () {},
                      icon: AppAssets.kApple,
                    ),
                    CustomSocialButton(
                      onTap: () {},
                      icon: AppAssets.kFacebook,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.twentyVertical),
                const AgreeTermsTextCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
