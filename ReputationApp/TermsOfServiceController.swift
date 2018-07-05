//
//  TermsOfServiceController.swift
//  ReputationApp
//
//  Created by Omar Torres on 6/02/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit

class TermsOfServiceController: UIViewController {
    
    let closeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "down_arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.text = "Acuerdo de licencia del usuario final de la aplicación\n\nEste Acuerdo de Licencia de Usuario Final ('Acuerdo') es entre usted y Dots y rige el uso de esta aplicación disponible a través del Apple App Store. Al instalar la aplicación Dots, acepta quedar obligado por este Acuerdo y entiende que no hay tolerancia para el contenido objetable. Si no está de acuerdo con los términos y condiciones de este Acuerdo, no tiene derecho a utilizar la aplicación Dots.\n\nPara garantizar que Dots proporcione la mejor experiencia posible para todos, aplicamos fuertemente una política de no tolerancia para contenido objetable. Si ve contenido inapropiado, utilice la función 'Informar como ofensivo' en cada publicación.\n\n1. Partes\n\nEste Acuerdo se establece entre usted y Dots y no Apple, Inc. ('Apple'). No obstante lo anterior, usted reconoce que Apple y sus subsidiarias son terceros beneficiarios de este Acuerdo y Apple tiene el derecho de hacer cumplir este Acuerdo contra usted. Dots, no Apple, es el único responsable de la aplicación Dots y su contenido.\n\n2. Privacidad\n\nDots puede recopilar y utilizar información sobre el uso de la aplicación Dots, incluyendo ciertos tipos de información de y sobre su dispositivo. Dots puede utilizar esta información, siempre y cuando esté en un formulario que no lo identifique personalmente, para medir el uso y el rendimiento de la aplicación Dots.\n\n3. Licencia limitada\n\nDots le otorga una licencia limitada, no exclusiva, no transferible y revocable para usar la aplicación Dots para sus fines personales y no comerciales. Sólo puedes usar la aplicación App App en dispositivos Apple que poseas o controlas y según lo permitan los Términos de servicio de la App Store.\n\n4. Restricciones de edad\n\nAl utilizar la aplicación Dots, usted declara y garantiza que tiene 17 años de edad o más y acepta estar obligado por este Acuerdo; (B) si usted es menor de 17 años de edad, ha obtenido el consentimiento verificable de un padre o tutor legal; Y (c) el uso de la aplicación Dots no viola ninguna ley o regulación aplicable. Su acceso a la aplicación Dots puede ser terminado sin previo aviso si Dots cree, a su sola discreción, que tiene menos de 17 años y no ha obtenido el consentimiento verificable de un padre o tutor legal. Si usted es padre o tutor legal y usted da su consentimiento para que su hijo use la aplicación Dots, usted acepta estar obligado por este Acuerdo con respecto al uso de la aplicación Dots por su hijo.\n\n5. Política de contenido objetable\n\nEl contenido no se puede enviar a Dots, que moderará todo el contenido y, en última instancia, decidirá si publicará o no una presentación en la medida en que dicho contenido incluya, esté en conjunción con, o junto con, Contenido objetable. El contenido objetable incluye, pero no se limita a: (i) materiales sexualmente explícitos; (Ii) contenido obsceno, difamatorio, difamatorio, calumnioso, violento y / o ilegal o profanidad; (Iii) contenido que infrinja los derechos de cualquier tercero, incluyendo derechos de autor, marca comercial, privacidad, publicidad u otro derecho personal o de propiedad, o que sea engañoso o fraudulento; (Iv) contenido que promueva el uso o venta de sustancias ilegales o reguladas, productos de tabaco, municiones y / o armas de fuego; Y (v) juegos de azar, incluyendo sin limitación, cualquier casino en línea, libros de deportes, bingo o póquer.\n\n6. Garantía\n\nDots renuncia a todas las garantías sobre la aplicación Dots en la medida máxima permitida por la ley. En la medida en que exista una garantía bajo la ley que no pueda ser rechazada, Dots no Apple, será el único responsable de dicha garantía.\n\n7. Mantenimiento y Soporte\n\nDots proporciona un mínimo de mantenimiento o soporte para ello, pero no en la medida en que la ley aplicable requiera cualquier mantenimiento o soporte, Dots, no Apple, estará obligado a proporcionar dicho mantenimiento o soporte.\n\n8. Reclamaciones de productos\n\nDots no Apple, es responsable de responder a cualquier reclamación relacionada con la aplicación Dots o uso de la misma, incluyendo pero no limitado a: (i) cualquier reclamación por responsabilidad del producto; (Ii) cualquier reclamación de que la App Dots no cumple con cualquier requisito legal o regulatorio aplicable; Y (iii) cualquier reclamación derivada de la protección del consumidor o legislación similar. Nada en este Acuerdo se considerará una admisión de que usted puede tener tales reclamaciones.\n\n9. Reclamaciones de propiedad intelectual de terceros\n\nDots no estará obligado a indemnizarlo o defenderlo con respecto a cualquier reclamación de terceros que surja o se relacione con la aplicación Dots. En la medida en que Dots esté obligado a proporcionar indemnización por la ley aplicable, Dots, no Apple, será el único responsable de la investigación, defensa, liquidación y descargo de cualquier reclamo de que la aplicación Infringe cualquier derecho de propiedad intelectual de terceros.\n\nInformación de contacto:\n\nSi tienes alguna sugerencia sobre estos Términos de Servicio o alguna queja, por favor contáctanos a torresomar44@gmail.com"
        tv.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tv.textColor = UIColor.grayLow()
        return tv
    }()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        view.addSubview(closeView)
        closeView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 30, height: 30)
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBackView)))
        
        closeView.addSubview(closeButton)
        closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        closeButton.centerXAnchor.constraint(equalTo: closeView.centerXAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: closeView.centerYAnchor).isActive = true
        closeButton.addTarget(self, action: #selector(goBackView), for: .touchUpInside)
        
        view.addSubview(messageTextView)
        messageTextView.anchor(top: closeView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 0)
        
    }
    
    @objc func goBackView() {
        self.dismiss(animated: true, completion: nil)
    }
}

