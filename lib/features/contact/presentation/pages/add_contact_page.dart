import 'dart:io';

import 'package:contact/config/extensions.dart';
import 'package:contact/core/models/event_status.dart';
import 'package:contact/core/router/app_router.dart';
import 'package:contact/core/router/screen_arguments.dart';
import 'package:contact/core/widgets/app_text_field.dart';
import 'package:contact/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:contact/features/contact/presentation/widgets/image_picker_dialog.dart';
import 'package:contact/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  File? pickedImage;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.onSecondary,
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => AppRouter.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
            ),
          ),
          title: Text(
            "Add new Contact",
            style: theme.textTheme.bodyMedium!
                .apply(color: theme.colorScheme.tertiary),
          ),
        ),
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () async {
                        ScreenArguments data = await ImagePickerDialog.show();
                        setState(() {
                          pickedImage = data.data;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.background,
                            ),
                            child: pickedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        Image.file(
                                          pickedImage!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.edit,
                                            color: theme.colorScheme.background,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo_rounded,
                                    color: theme.colorScheme.tertiary,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: firstNameController,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            hintText: "first name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please fill your first name";
                              } else if (value.isNotEmpty && value.length < 3) {
                                return 'First name must be more than 2 charater';
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: lastNameController,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            hintText: "last name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please fill your last name";
                              } else if (value.isNotEmpty && value.length < 3) {
                                return "Last name must be more than 2 charater";
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: phoneController,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            hintText: "phone number",
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.validateMobile,
                          ),
                          AppTextField(
                            controller: emailController,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            hintText: "email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.validateEmail,
                          ),
                          AppTextField(
                            controller: noteController,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            hintText: "note",
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter note";
                              }
                              return null;
                            },
                          ),
                          BlocConsumer<ContactBloc, ContactState>(
                            listener: (context, state) {
                              if (state.createNewContactStatus
                                  is EventCompleted) {
                                BlocProvider.of<HomeBloc>(context).add(
                                    AddNewContactToListEvent(
                                        newContact:
                                            (state.createNewContactStatus
                                                    as EventCompleted)
                                                .data));
                                AppRouter.pop();
                              }
                              if (state.createNewContactStatus is EventError) {
                                AppRouter.pop();
                              }
                            },
                            listenWhen: (previous, current) => previous.createNewContactStatus != current.createNewContactStatus,
                            buildWhen: (previous, current) => previous.createNewContactStatus != current.createNewContactStatus,
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.createNewContactStatus
                                        is EventLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          BlocProvider.of<ContactBloc>(context)
                                              .add(
                                            CreateContactEvent(
                                              firstName:
                                                  firstNameController.text,
                                              lastName: lastNameController.text,
                                              email: emailController.text,
                                              phone: phoneController.text,
                                              note: noteController.text,
                                              picture: pickedImage,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 32)),
                                child: state.createNewContactStatus
                                        is EventLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: theme.colorScheme.background,
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                          ),
                                          Text(
                                            "save",
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
