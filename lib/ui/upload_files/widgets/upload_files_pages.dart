import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:diakron_collection_center/ui/core/themes/dimens.dart';
import 'package:diakron_collection_center/ui/core/ui/custom_text_form_field.dart';
import 'package:diakron_collection_center/ui/upload_files/view_models/upload_files_viewmodel.dart';
import 'package:diakron_collection_center/ui/upload_files/widgets/file_picker_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Company data
class UploadFilesStep1Page extends StatelessWidget {
  const UploadFilesStep1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UploadFilesViewModel>();

    return Form(
      key: vm.step1FormKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Datos de la empresa y representante",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          CustomTextFormField(
            labelText: "Razón social / Nombre legal de la empresa",
            controller: vm.companyNameController,
            validator: Validators.required,
          ),

          CustomTextFormField(
            labelText: "Nombre comercial (será visible públicamente)",
            controller: vm.commercialNameController,
            validator: Validators.required,
          ),

          CustomTextFormField(
            labelText: "Dirección fiscal",
            controller: vm.addressController,
            validator: Validators.required,
          ),

          CustomTextFormField(
            labelText: "Código postal de dirección fiscal",
            controller: vm.postCodeController,
            keyboardType: TextInputType.number,
            validator: Validators.postCode,
          ),

          ListenableBuilder(
            listenable: vm,
            builder: (context, child) {
              final timeErrorMsj = vm.timeErrorMsj;
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      "Horario de apertura: ${vm.openTime ?? '--:--'}",
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) vm.updatePath('openTime', time);
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Horario de cierre: ${vm.closeTime ?? '--:--'}",
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) vm.updatePath('closeTime', time);
                    },
                  ),
                  if (timeErrorMsj != null)
                    Text(
                      timeErrorMsj,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),

          CustomTextFormField(
            labelText: "CURP del representante",
            controller: vm.curpController,
            validator: Validators.curp,
          ),
        ],
      ),
    );
  }
}

// Billing data
class UploadFilesStep2Page extends StatelessWidget {
  const UploadFilesStep2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UploadFilesViewModel>();
    return Form(
      key: vm.step2FormKey,
      child: ListView(
        padding: const EdgeInsets.all(24),        
        children: [
          const Text(
            "Información fiscal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          CustomTextFormField(
            labelText: "Correo electrónico de facturación",
            controller: vm.billingEmailController,
            validator: Validators.email,
          ),

          SizedBox(height: 10),

          Text(
            style: TextStyle(fontSize: Dimens.fontMedium),
            "Tipo de contribuyente empresa"),
          SizedBox(height: 10),

          ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              return
               RadioGroup<TaxpayerType>(
                groupValue: vm.currentType,
                onChanged: (TaxpayerType? value) {
                  vm.setTaxpayerType(value);
                },
                child: const
              Column(
                children: [
                  RadioListTile<TaxpayerType>(
                    title: Text("Persona Moral"),
                    value: TaxpayerType.moral,
                    activeColor: AppColors.greenDiakron1,
                  ),
                  RadioListTile<TaxpayerType>(
                    title: Text("Persona Física"),
                    value: TaxpayerType.physical,
                    activeColor: AppColors.greenDiakron1,
                  ),
                ],
                ),
              );
            },
          ),
          SizedBox(height: 10),

          CustomTextFormField(
            labelText: "Régimen fisal de la empresa",
            controller: vm.taxRegimeController,
            validator: Validators.required,
          ),
          CustomTextFormField(
            labelText: "RFC de la empresa",
            controller: vm.rfcController,
            validator: Validators.required,
          ),

          CustomTextFormField(
            labelText: "Banco de operaciones",
            controller: vm.bankController,
            validator: Validators.required,
          ),

          CustomTextFormField(
            labelText: "CLABE",
            controller: vm.clabeController,
            validator: Validators.clabe,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

// Docs data
class UploadFilesStep3Page extends StatelessWidget {
  const UploadFilesStep3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadFilesViewModel>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Documentación PDF",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        FilePickerTile(
          label: "Identificación Representante",
          path: vm.pathIdRep,
          onPick: () => _pickPDF(context, 'pathIdRep'),
        ),
        FilePickerTile(
          label: "Comprobante de Domicilio",
          path: vm.pathProofAddress,
          onPick: () => _pickPDF(context, 'pathProofAddress'),
        ),
        FilePickerTile(
          label: "Constancia Situación Fiscal",
          path: vm.pathTaxCertificate,
          onPick: () => _pickPDF(context, 'pathTaxCertificate'),
        ),
      ],
    );
  }

  Future<void> _pickPDF(BuildContext context, String field) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = result.files.single;
      // Check 10 MB limit
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("El archivo supera los 10 MB")),
        );
        return;
      }
      // If its ok the size, save current file path
      context.read<UploadFilesViewModel>().updatePath(field, file.path);
    }
  }
}
