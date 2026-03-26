import 'package:diakron_collection_center/ui/core/ui/form_input_text.dart';
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

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Datos de la empresa y representante",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        FormInputText(
          labelText: "Razón social / Nombre legal",
          controller: vm.companyNameController,
        ),

        FormInputText(
          labelText: "Nombre comercial (visible públicamente)",
          controller: vm.commercialNameController,
        ),

        FormInputText(labelText: "Dirección", controller: vm.addressController),

        ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            return ListTile(
              title: Text("Horario de apertura: ${vm.openTime ?? '--:--'}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) vm.updatePath('openTime', time);
              },
            );
          },
        ),
        ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            return ListTile(
              title: Text("Horario de cierre: ${vm.closeTime ?? '--:--'}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) vm.updatePath('closeTime', time);
              },
            );
          },
        ),

        FormInputText(
          labelText: "CURP del representante",
          controller: vm.curpController,
        ),
      ],
    );
  }
}

// Billing data
class UploadFilesStep2Page extends StatelessWidget {
  const UploadFilesStep2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<UploadFilesViewModel>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Información fiscal",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        FormInputText(
          labelText: "Correo electrónico de facturación",
          controller: vm.billingEmailController,
        ),

        FormInputText(
          labelText: "Tipo de contribuyente (persona moral/física)",
          controller: vm.taxpayerTypeController,
        ),

        FormInputText(
          labelText: "Régimen fisal de la empresa",
          controller: vm.taxRegimeController,
        ),
        FormInputText(
          labelText: "RFC de la empresa",
          controller: vm.rfcController,
        ),


        FormInputText(
          labelText: "Banco de operaciones",
          controller: vm.bankController,
        ),

        FormInputText(labelText: "CLABE", controller: vm.clabeController),
      ],
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
      context.read<UploadFilesViewModel>().updatePath(
        field,
        result.files.single.path,
      );
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
