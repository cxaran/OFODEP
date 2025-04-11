import 'package:flutter/material.dart';

class TermsCreateStore extends StatelessWidget {
  const TermsCreateStore({super.key});

  final String _termsText = '''
TÉRMINOS Y CONDICIONES PARA LA SOLICITUD DEL PERÍODO DE PRUEBA Y ACUERDO COMERCIAL INTEGRAL

1. Objeto
Estos Términos y Condiciones regulan la solicitud del período de prueba gratuito del servicio ofrecido a través de la plataforma. El envío del formulario implica que el comercio acepta participar en un proceso integral de evaluación, en el que se negocian simultáneamente los términos comerciales, incluyendo precios y otras condiciones económicas.

2. Proceso de Solicitud y Evaluación
- Solicitud Inicial:  
  El comercio interesado completa el formulario en línea proporcionando la información de contacto y los datos generales del negocio.
- Contacto y Evaluación:  
  Una vez recibido el formulario, un representante se pondrá en contacto para recabar la información adicional necesaria y evaluar la elegibilidad del comercio. Se analizarán aspectos como la veracidad de la información, la ubicación y la modalidad de atención (delivery/pickup), entre otros.
- Decisión Integral:  
  La aprobación del período de prueba y la determinación de los términos comerciales (precios, métodos de pago, etc.) se realizan de forma conjunta y discrecional por el equipo responsable. El envío del formulario no garantiza la aprobación automática; inicia el proceso de negociación integral.

3. Alcance y Limitaciones del Período de Prueba
- Duración y Funcionalidades:  
  El período de prueba tendrá una duración y condiciones específicas, que serán comunicadas al comercio durante el proceso de contacto. Durante este tiempo se activarán determinadas funcionalidades básicas para que se pueda evaluar el servicio.
- Limitaciones:  
  Es posible que no todas las funcionalidades del servicio completo estén disponibles en el período de prueba. La plataforma se reserva el derecho de establecer restricciones específicas según las características del comercio y los resultados de la evaluación.

4. Acuerdo Comercial Integral
- Negociación Conjunta:  
  El período de prueba se formaliza simultáneamente con la definición de los términos comerciales, integrándose en un único acuerdo que se plasmará en un contrato. Dicho contrato regulará tanto el acceso al servicio en el período de prueba como las condiciones para su continuidad.
- Compromiso y Formalización:  
  Al participar en este proceso, el comercio se compromete a negociar de buena fe los términos económicos y comerciales. Una vez alcanzado un acuerdo, los términos se reflejarán en el contrato definitivo que regirá la prestación del servicio.
- Condiciones Económicas:  
  Los precios, métodos de pago y demás condiciones se definirán durante la negociación, pudiendo incluir ajustes o condiciones especiales según la evaluación realizada.

5. Declaración y Veracidad de la Información
El comercio declara que la información suministrada es veraz y completa, y que cuenta con la autorización necesaria para representar al negocio. En caso de detectarse información errónea o incompleta, la plataforma podrá rechazar o suspender la solicitud sin previo aviso.

6. Confidencialidad y Uso de Datos
Los datos recopilados serán utilizados exclusivamente para fines de contacto, validación y gestión interna del servicio. La información se tratará de forma confidencial y no se compartirá con terceros no autorizados, salvo en casos legales o cuando sea estrictamente necesario para formalizar el contrato integral.

7. Modificaciones y Actualizaciones
La plataforma se reserva el derecho de modificar estos Términos y Condiciones en cualquier momento. Cualquier cambio se comunicará al comercio antes de que este confirme su aceptación del período de prueba y los términos comerciales, de modo que el contrato final refleje las condiciones vigentes.

8. Aceptación de los Términos
El envío del formulario de solicitud implica la aceptación total y sin reservas de estos Términos y Condiciones. La aprobación del proceso integral (período de prueba y negociación de condiciones comerciales) se formalizará mediante un contrato en el que se detallen todas las condiciones técnicas y económicas del servicio.


Impacto en el Proceso de Servicio

• Claridad y Transparencia:  
  El comercio conocerá desde el inicio que su solicitud se vincula directamente a la negociación conjunta de precios y condiciones, evitando malentendidos.

• Compromiso Integral:  
  Al integrar la evaluación del servicio y la negociación de términos en un único proceso, se facilita la toma de decisiones y la formalización del acuerdo.

• Seguridad Jurídica:  
  La inclusión de estos Términos y Condiciones proporciona un marco legal que protege tanto a la plataforma como al comercio, garantizando el cumplimiento de sus respectivas obligaciones y derechos.

• Flexibilidad y Adaptación:  
  La plataforma podrá ajustar y negociar las condiciones de forma personalizada, atendiendo a las características específicas de cada comercio.

''';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Text(
          _termsText,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        )
      ],
    );
  }
}
