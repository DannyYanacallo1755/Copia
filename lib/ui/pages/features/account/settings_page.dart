

import '../../pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) { 
    final AppLocalizations translations =  AppLocalizations.of(context)!;
    final ThemeData theme =  Theme.of(context);
    final Size size = MediaQuery.of(context).size;

    void showBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: size.height * 0.50,
            color: Colors.white,
            child: const Center(
              child: Text('This is a Bottom Sheet'),
            ),
          );
        },
      );
    }

    final List<SettignsOptions> options = [
      SettignsOptions(
        title: translations.deliver_to, 
        mode: SettingsOptionsMode.Deliver,
        onClick: () => showBottomSheet(context)
      ),
      SettignsOptions(
        title: translations.currency, 
        mode: SettingsOptionsMode.Currency,
        onClick: () => showBottomSheet(context)
      ),
      SettignsOptions(
        title: translations.language, 
        mode: SettingsOptionsMode.Language,
        onClick: () => showBottomSheet(context)
      ),
    ];

    


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final SettignsOptions option = options[index];
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 10.0: 0.0) ,
            child: ListTile(
              shape: theme.listTileTheme.copyWith(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
              ).shape,
              selected: false,
              tileColor: Colors.white,
              titleTextStyle: theme.textTheme.labelMedium?.copyWith(color: Colors.black),
              title: Text(option.title),
              onTap: () => option.onClick(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 15.0),
            ),
          );
        },
      ),
    );
    
  }
}

class SettignsOptions{
  final String title;
  final SettingsOptionsMode mode;
  final Function onClick;

  const SettignsOptions({
    required this.title,
    required this.mode,
    required this.onClick,
  });
}

enum SettingsOptionsMode{
  Language,
  Currency,
  Deliver
}