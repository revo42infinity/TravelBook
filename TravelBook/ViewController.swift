//
//  ViewController.swift
//  TravelBook
//
//  Created by owner on 10/10/20.
//  Copyright © 2020 Caner Duru. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation //location almak icin
import CoreData

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {

    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager() //konumla alakali birsey yapiyorsaniz.kullanici konumunu alacaksak islem yapacaksak kendi haritamda gostericeksem bunu kullanman lazim. cllocationmanager
    var chosenLatitude = Double()   //newplaceleri yazdiktan sonra yapiyoruz bu kismi.koordinatlari almak icin
    var chosenLongitude = Double()
 //17
    var selectedTitle = ""
    var selectedTitleID : UUID?
 //27
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //mapview calismasi icin delegate
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //location ne kadar keskin olsun diye
        locationManager.requestWhenInUseAuthorization() //izin aliyor kullanirken
        locationManager.startUpdatingLocation() //yerini bu kelime ile birlikte almaya basliyoruz
        
        
        //pin olusturmak icin
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        
        gestureRecognizer.minimumPressDuration = 3 // 3 saniye basili tutunca baslasin
        mapView.addGestureRecognizer(gestureRecognizer) //az once olusturdugumuz gesture i koyduk ama bundan once kac sn basmali onu yazalim yukarida
        
        
//18
        if selectedTitle != "" { //bos degil ise
            //coredatadan cekecegiz
 //23 ornek olsun diye yapildi basinca diger ekranda kaydi gosteriyor ama pin ekleme yapilmadi henuz
  //23          let strinUUID = selectedTitleID!.uuidString //boylce listedekine tiklayinca diger ekranda gosteriyor ne kayitli oldugunu
  //23          print(strinUUID)
            
            
 //24
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")

//25 asagidakini predicate dan sonra yaziyoruz
            let idString = selectedTitleID!.uuidString //bunu yaptiktan sonra predicate daki argumana idstring yazacagiz
            
//24 predicate yaziyoruz. returns object yazmistik sonra predicate kodu
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString) //filtre ekliyoruz
            fetchRequest.returnsObjectsAsFaults = false
            
            //yukaridakini yaptik. boylece id si idstring e esit olanlari cagiriyoruz.
 
//26
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] { //artik istedigimizi alacagiz asagidaki gibi yazarak
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
 //30 hepsii ayni anda istiyorsak. yani if title icin calisacak sonra subtitle sonra vs vs . hepsini kontrol ediyor
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        
  //31
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
  //32
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
  //33 yer degisince diye buunu yapiyoruz. arka planda kullanici nerde biliyoruz. yolda yurudu diye harita degismesin istiyorum. yani mevcut lokasyon  arti tusuna basinca gelecek ama kayitli olanlara basinca kayitli olan location gelecek
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true) //selectedtitle bosdegilse de gerceklesecek
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        
// 29 icine atiyoruz      if let subtitle = result.value(forKey: "subtitle") as? String {
//                            annotationSubtitle = subtitle                                                   //28
//                        }
//                        if let latitude = result.value(forKey: "latitude") as? Double {
//                            annotationLatitude = latitude                                //28
//                        }
//                        if let longitude = result.value(forKey: "longitude") as? Double {
//                            annotationLongitude = longitude                                  //28
//                        }
                    
                    }
                    
                }
            } catch {
                print("error")
            }
            
        } else {
            //add new data
        }
        
    }
    
    //selector func yazacagiz. ismi chooseLocation olsun
    @objc func chooseLocation (gestureRecognizer:UILongPressGestureRecognizer){ //chooselocation input almasi lazim. gesturerecognizer yaziyoruz
     
        //3 sn basinca alacagi koordinatlara gore pin olusturmamiz lazim
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // hangi view icindeki lokasyon? mapview... touchedpoint biz isim verdik. bunu alabilmek icin gesturerecognizer.... nereye dokunuldugunu cikartiyor burada
            
            //dokunulan noktayi koordinata ceviriyoruz.self demeye cok gerek yok aslinda
            let touchCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) //mapview dan dokunulan noktayi al
            
            
            // bu kismi newplaces den sonra yukarida longitude lari olusturduktan sonra yapiyoruz.kullanici her dokundugunda eylem ve boylamlar degisecek. degistikten sonra save buttona basinca kaydediyoruz
            chosenLatitude = touchCoordinates.latitude
            chosenLongitude = touchCoordinates.longitude
            
            
            //pini olusturmak. annotation
            let annotation = MKPointAnnotation() //annotation a istenien kordinat verilir
            annotation.coordinate = touchCoordinates //coordinate verelim
//            annotation.title = "New Annotation"
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
//            annotation.subtitle = "Travel Book"
            //artik ekleyelim
            self.mapView.addAnnotation(annotation) //olusturdugumuz annotationi girdik
            
            
            
        
            
             
        }
        
        
    }
    
    
//kullanicinin locationini aldigimizda ne yapacagiz? didupdatelocation guncellenen locationlari cllocation seklinde dizi icinde veriyor. cll enlem ve boylam baridniriyor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 //34 sadece bos ise beni al haritami degistir icin bu asagidakini yapacagiz
        if selectedTitle == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //kullanicinin o anki lokasyonunu aliyor
        //haritada gosterebilmek icin zoom yapmak lazim. zoom seviyesi icin span kullaniyoruz
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //zoom seviyesi. 0.1 kullandik. ne kadar kucukse o kadar zoom
        
        let region = MKCoordinateRegion(center: location, span: span) //bizim olusturdugumuz location ve span girdik. region olusturduk
        mapView.setRegion(region, animated: true) //bizim olusturdugumuz region girdik
        }else {                                 //34
        
        }
            
        
            //belirtilen enlem ve boylama zoomlayacak
        
    }
    
    //37
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //annotationview olsutrmak gerecek burda istiyor cunku. mkpinannot da oluyor
    //38
        if annotation is MKUserLocation {
            return nil //kullanicinin yerini pinle gostermek istemiyoruz
        }
        let reuseId = "my Annotation" //pinview da identifier icin olusturduk
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    //39 bu kontrolu yapacagiz.oinview olusturulmadiysa olusturmaya basliyoruz
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //baloncukla gosterme
            pinView?.tintColor = UIColor.black //rengini yazdik
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) //detay gosterecegimizbutton
            pinView?.rightCalloutAccessoryView = button //sagda
            
            
        } else{ //eger pinview bos degilse onceden olusturulduysa
            pinView?.annotation = annotation //bana daha once verilen annotation
            
        }
        
        
        
        return pinView
    }
    
    
    //40 buttonda cikan i isaretine tiklandigini anlayacagiz once. sonra i yi aktif edecegiz.calloutaccesory oraya tiklandigini anliyor. sonra secilen bir yer varmi ona bakalim. secilen yoksa enlem boylam yok cunku
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != ""{
            //bos degilse secilmis enlem ve boylam var demektir.o enlem ve boylami annotationlattitude ve longitude da sakliyoruz zaten
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in //bu yapiya closure deniyor. bir islem yapiyorsunuz sonunda size birsey verilecek. sonucunda ya hata veriyor ya da placemark bulunan dizi veriyor. bu sekilde navigasyon baslatilacak .geocodelocation calisitirinca gitmek istedigim yeri gosteren bir obje olacak. o obje kullanilarak navigasyon kbaslatilacak. clgeocoder navigasyonu calistirmak icin gerekli objeyi almak icin isimize yariyor.placemark denilen objeyi kullanarak navig baslatilacak
                if let placemark = placemarks {
                    if placemark.count > 0 { //placemark optional oldugu icin gerecekten varmi onu kontrol ediyoruz
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)         //nasil calistirilacagini gosterelim. item olusturuyoruz
                        item.name = self.annotationTitle
                        //bu item i kullanarak navigasyonu acabiliriz
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving] //nasil gidecegimi soruyor. arabayi surerek mesela.nasil navigate olacak.
                        item.openInMaps(launchOptions: launchOptions)
                        //yukaridaki islemlerin anlami naigasyonu acabilmemiz icin map item olsuturmak lazim. hang modda olacak onu istiyor.map item olusturmak icin placemark lazim. bunuda reversgeocode metodu ile aliniyor.
                    
                }
             }
        }
        }
        
    }
    @IBAction func saveButton(_ sender: Any) {
        
        
        //pinleri ekledikten sve button ekledikten sonra coredata import et once. sonra kaydetmeler icin appdelegate cagiriyoruz. sonra nsentity cagiricaz.newobject. context kullanarak yeni fegerler atayip kaydedicez
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //nsentitydesc olusturucaz. kullanicin kaydetmek istedigi verileri koyacagimiz yer
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "Title")
        newPlace.setValue(commentText.text, forKey: "Subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        //boylece istedigimiz 5 degeri kaydettik
        
        do{
            try context.save()
            print("success")
            
        } catch {
            print("error")
        }
        
 //35
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlace"), object: nil) //butun app e mesaj atiyor.diger tarafta observer kullanarak newplace mesaji gelince napacagiizi soyleyebiliyoruz
        navigationController?.popViewController(animated: true) //bir onceki view controller a geri goturuyor
    
       
        
        
        
        
    }
    
    
}

