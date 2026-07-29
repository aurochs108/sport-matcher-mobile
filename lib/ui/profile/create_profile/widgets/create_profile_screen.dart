import 'package:flutter/material.dart';
import 'package:sport_matcher/ui/profile/create_profile/widgets/create_profile_screen_model.dart';
import 'package:sport_matcher/ui/profile/widgets/profile_form_fields_view.dart';

class CreateProfileScreen extends StatelessWidget {
  CreateProfileScreen({super.key});

  final _viewModel = CreateProfileScreenModel();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Create profile"),
        ),
        body: ProfileFormFieldsView(
          buttonTitle: "Next",
          saveProfile: _viewModel.createProfile,
          onSaved: () => _viewModel.navigateToHomeAction(Navigator.of(context)),
          onSaveFailed: (message) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(message), backgroundColor: Colors.red),
              );
          },
        ),
      ),
    );
  }
}
