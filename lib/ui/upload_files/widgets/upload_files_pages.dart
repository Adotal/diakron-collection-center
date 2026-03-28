import 'package:diakron_collection_center/ui/core/themes/colors.dart';
import 'package:diakron_collection_center/ui/core/themes/dimens.dart';
import 'package:diakron_collection_center/ui/core/ui/custom_text_form_field.dart';
import 'package:diakron_collection_center/ui/upload_files/view_models/upload_files_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
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
        _FilePickerTile(
          label: "Identificación Representante",
          path: vm.pathIdRep,
          onPick: () => _pickPDF(context, 'pathIdRep'),
        ),
        _FilePickerTile(
          label: "Comprobante de Domicilio",
          path: vm.pathProofAddress,
          onPick: () => _pickPDF(context, 'pathProofAddress'),
        ),
        _FilePickerTile(
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

class _FilePickerTile extends StatelessWidget {
  final String label;
  final String? path;
  final VoidCallback onPick;

  const _FilePickerTile({required this.label, this.path, required this.onPick});

  @override
  Widget build(BuildContext context) {
    bool hasFile = path != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: hasFile ? Colors.green : Colors.grey.shade300),
      ),
      color: hasFile ? Colors.green.shade50 : Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          hasFile ? Icons.picture_as_pdf : Icons.upload_file,
          color: hasFile ? Colors.green : Colors.grey,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          hasFile
              ? "Presiona para cambiar archivo"
              : "Toca para seleccionar PDF",
          style: TextStyle(
            fontSize: 12,
            color: hasFile ? Colors.green.shade700 : Colors.grey,
          ),
        ),
        // BOTÓN PARA ABRIR EL DOCUMENTO
        trailing: hasFile
            ? IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () async {
                  // Lógica para abrir el archivo local
                  if (path != null) {
                    await OpenFilex.open(path!);
                  }
                },
                tooltip: "Ver documento",
              )
            : const Icon(Icons.chevron_right),
        onTap:
            onPick, // El área general sigue sirviendo para cambiar el archivo
      ),
    );
  }
}
