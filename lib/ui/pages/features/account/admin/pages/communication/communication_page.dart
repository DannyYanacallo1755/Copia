import 'package:ourshop_ecommerce/ui/pages/pages.dart';


enum CommuniactionMode {
  view,
  edit,
}

class AdminCommunicationPage extends StatefulWidget {
  const AdminCommunicationPage({super.key});

  @override
  State<AdminCommunicationPage> createState() => _AdminCommunicationPageState();
}

class _AdminCommunicationPageState extends State<AdminCommunicationPage> {

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fetchAdminProducts();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void fetchAdminProducts() {
    context.read<CommunicationBloc>().add(AddFilteredRequests(
        companyId: context.read<UsersBloc>().state.loggedUser.companyId, 
        page: 1
      )
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && context.read<CommunicationBloc>().state.status != CommunicationStatus.loadingmore) {
        context.read<CommunicationBloc>().add(AddFilteredRequests(
            companyId: context.read<UsersBloc>().state.loggedUser.companyId, 
            page: context.read<CommunicationBloc>().state.currentPage + 1
          )
        );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }


  final ValueNotifier<CommuniactionMode> mode = ValueNotifier<CommuniactionMode>(CommuniactionMode.view);
  final ValueNotifier<FilteredRequests> selectedRequest = ValueNotifier<FilteredRequests>(const FilteredRequests());
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  
  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodyLarge?.copyWith();
    final Size size = MediaQuery.of(context).size;
    const Widget spacer = SizedBox(height: 10,);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (mode.value == CommuniactionMode.edit) {
              mode.value = CommuniactionMode.view;
              return;
            }
            context.pop();
          },
        ),
        title: Text(translations.comunication, style: style,),
      ),
      body: ValueListenableBuilder<CommuniactionMode>(
        valueListenable: mode,
        builder: (BuildContext context, value, Widget? child) {
          if (value == CommuniactionMode.edit) {
            return FormBuilder(
              key: formKey,
              child: Padding( 
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    FormBuilderTextField(
                      initialValue: selectedRequest.value.fullName,
                      name: 'full_name',
                      decoration: InputDecoration(
                        labelText: translations.name,
                        hintText: translations.name,
                      ),
                    ),
                    spacer,
                    FormBuilderTextField(
                      initialValue: selectedRequest.value.email,
                      name: 'email',
                      decoration: InputDecoration(
                        labelText: translations.email,
                        hintText: translations.email,
                      ),
                    ),
                    spacer,
                    FormBuilderTextField(
                      initialValue: selectedRequest.value.phoneNumber,
                      name: 'phone',
                      decoration: InputDecoration(
                        labelText: translations.phone,
                        hintText: translations.phone,
                      ),
                    ),
                    spacer,
                    FormBuilderTextField(
                      initialValue: selectedRequest.value.title,
                      name: 'title',
                      decoration: InputDecoration(
                        labelText: translations.title,
                        hintText: translations.title,
                      ),
                    ),
                    spacer,
                    FormBuilderTextField(
                      initialValue: selectedRequest.value.message,
                      name: 'message',
                      decoration: const InputDecoration(
                        labelText: 'message',
                        hintText: 'message',
                      ),
                    ),
                    
                  ],
                ),
              ),
            );
          }
          return child!;
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: size.height,
          width: size.width,
          child: BlocBuilder<CommunicationBloc, CommunicationState>(
            builder: (context, state) {
              if (state.status == CommunicationStatus.loading) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
        
              if (state.status == CommunicationStatus.error) {
                return Center(child: Text(translations.error, style: style,));
              }
        
              if (state.filteredRequests.isEmpty) {
                return Center(child: Text('No data', style: style,));
              }
        
              return ListView.builder(
                    itemCount: state.hasMore
                      ? state.filteredRequests.length + 1 
                      : state.filteredRequests.length,
                    itemBuilder: (context, index) {
                      if (index >= state.filteredRequests.length) {
                        return const Center(child: CircularProgressIndicator.adaptive());
                      }
                      final FilteredRequests request = state.filteredRequests[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.primaryColor.withOpacity(0.1),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            ListTile(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              title: Text('${translations.name} : ${Helpers.truncateText(request.fullName ?? '', 20)}', style: style,),
                              trailing: IconButton(
                                onPressed: () {
                                  selectedRequest.value = request;
                                  mode.value = CommuniactionMode.edit;
                                },
                                icon: const Icon(Icons.remove_red_eye)
                              ),
                              // subtitle: Text(translations.email, style: style,),
                            ),
                            ListTile(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              title: Text('${translations.email} : ${request.email}', style: style,)
                            ),
                            ListTile(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              title: Text('${translations.phone} : +${request.phoneNumberCode} ${request.phoneNumber}', style: style,),
                            ),
                            ListTile(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              title: Text('${translations.title} : ${request.title}', style: style,),
                              // subtitle: Text('title', style: style,),
                            ),
                          ],
                        ),
                      );
                    },
                  );
            },
          )
        ),
      ),
    );
  }
}