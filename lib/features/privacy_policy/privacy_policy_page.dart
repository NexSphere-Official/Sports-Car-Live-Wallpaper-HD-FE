import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'privacy_policy_cubit.dart';
import 'privacy_policy_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final PrivacyPolicyCubit cubit;

  const PrivacyPolicyPage({super.key, required this.cubit});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  PrivacyPolicyCubit get cubit => widget.cubit;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    cubit.onInit();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => cubit.onPageStarted(),
          onProgress: (progress) => cubit.onProgress(progress),
          onPageFinished: (_) => cubit.onPageFinished(),
        ),
      )
      ..loadRequest(Uri.parse(cubit.initialParams.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(title: cubit.initialParams.title, onBack: cubit.onTapBack),
            BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
              bloc: cubit,
              builder: (context, state) {
                if (!state.isLoading) return const SizedBox(height: 2);
                return LinearProgressIndicator(
                  value: state.progress == 0 ? null : state.progress / 100,
                  minHeight: 2,
                  color: AppColors.accent,
                  backgroundColor: context.palette.surfaceHigh,
                );
              },
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          GlassPanel(
            borderRadius: 100,
            blur: 14,
            onTap: onBack,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
