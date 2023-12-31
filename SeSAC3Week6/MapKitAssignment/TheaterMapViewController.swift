//
//  TheaterMapViewController.swift
//  SeSAC3Week6
//
//  Created by 김지연 on 2023/08/23.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

enum ViewType: String {
    case all, lotte, megabox, cgv
}

class TheaterMapViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    
    let mapView = MKMapView()
    let totalButton = setButton(title: "전체보기")
    let lotteButton = setButton(title: "롯데시네마")
    let megaBoxButton = setButton(title: "메가박스")
    let cgvButton = setButton(title: "CGV")
    let locationButton = {
        let btn = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.buttonSize = .small
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.titleAlignment = .center
        //config.image = UIImage(systemName: "location.circle")
        btn.configuration = config
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 1
        btn.setImage(UIImage(systemName: "location.circle"), for: .normal)
        
        
        return btn
    }()
    
    var annoList: [MKPointAnnotation] = []
    var lotteList: [MKPointAnnotation] = []
    var megaList: [MKPointAnnotation] = []
    var cgvList: [MKPointAnnotation] = []
    
    lazy var stackView = {
        let stackview = UIStackView(arrangedSubviews: [totalButton, lotteButton, megaBoxButton, cgvButton])
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.alignment = .fill
        
        stackview.spacing = 10
        return stackview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        mapView.delegate = self
        checkDeviceLocationAuthorization()
        
        setConstraints()
        setAttribute()
        setAnnotationList()
        setAnnotation(type: .all)
        
        
    }
    
  
    
    func setAnnotationList() {
        for item in TheaterList().mapAnnotations {
            
            let anot = MKPointAnnotation()
            anot.coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            anot.title = item.location
            annoList.append(anot)
            if item.type == "롯데시네마" {
                lotteList.append(anot)
            } else if item.type == "메가박스" {
                megaList.append(anot)
            } else if item.type == "CGV" {
                cgvList.append(anot)
            }
        }
    }
    
    
    
    func setAnnotation(type: ViewType) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        switch type {
        case .all:
            mapView.addAnnotations(annoList)
            mapView.setCenter(annoList[0].coordinate, animated: true)
        case .lotte:
            mapView.addAnnotations(lotteList)
            mapView.setCenter(lotteList[0].coordinate, animated: true)
        case .megabox:
            mapView.addAnnotations(megaList)
            mapView.setCenter(megaList[0].coordinate, animated: true)
        case .cgv:
            mapView.addAnnotations(cgvList)
            mapView.setCenter(cgvList[0].coordinate, animated: true)
        }
        

        
        
    }
    
    
    func checkDeviceLocationAuthorization() {
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: authorization)
                }
                
            } else {
                self.showRequestLocationServiceAlert()
                print("위치 서비스가 꺼져 있어서 위치 권한 요청을 못합니다.")
            }
        }
        
    }
    
    
    
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            showRequestLocationServiceAlert()
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .authorized:
            print("authorized")
        @unknown default: print("default")
        }
        
    }
    
    func setRegionAndAnnotation(center: CLLocationCoordinate2D){
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
    }
    
    
    
    
    
    
    /*
     Location Authorization Custom Alert
     */

    func showRequestLocationServiceAlert() {
      let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
      let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
        
      }
      let cancel = UIAlertAction(title: "취소", style: .default)
      requestLocationServiceAlert.addAction(cancel)
      requestLocationServiceAlert.addAction(goSetting)
      
      present(requestLocationServiceAlert, animated: true, completion: nil)
    }

}

extension TheaterMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let coordinate = locations.last?.coordinate {
            setRegionAndAnnotation(center: coordinate)
        }
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let center = CLLocationCoordinate2D(latitude: 37.51800, longitude: 126.88641)
        setRegionAndAnnotation(center: center)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkDeviceLocationAuthorization()
    }
    
    
    
}

extension TheaterMapViewController {
    

    func setAttribute() {
        
        totalButton.addTarget(self, action: #selector(clickedTotalButton), for: .touchUpInside)
        lotteButton.addTarget(self, action: #selector(clickedLotteButton), for: .touchUpInside)
        megaBoxButton.addTarget(self, action: #selector(clickedMegaButton), for: .touchUpInside)
        cgvButton.addTarget(self, action: #selector(clickedCGVButton), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(clickedLocationButton), for: .touchUpInside)
    }
    
    @objc func clickedLocationButton() {
        checkDeviceLocationAuthorization()
        //locationManager.startUpdatingLocation()
    }
    @objc func clickedTotalButton() {
        setAnnotation(type: .all)
    }
    @objc func clickedLotteButton() {
        setAnnotation(type: .lotte)
    }
    @objc func clickedMegaButton() {
        setAnnotation(type: .megabox)
    }
    @objc func clickedCGVButton() {
        setAnnotation(type: .cgv)
    }
    
    
    static func setButton(title: String) -> UIButton {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.buttonSize = .small
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .darkGray
        config.titleAlignment = .center
        
        button.configuration = config
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        return button
    }
    
    func setConstraints() {
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(mapView).inset(20)
            make.topMargin.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailingMargin.equalTo(mapView.snp.trailing).inset(20)
            make.bottomMargin.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        totalButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(stackView)
        
        }
        
        lotteButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(stackView)
        }
        
        
        megaBoxButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(stackView)
        }
        
        
        cgvButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(stackView)
        }
        
    }
    
    
    
}

extension TheaterMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(#function)
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print(#function)
    }
}

