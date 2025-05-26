//
//  FManager.swift
//  app_ios
//
//  Created by Vinh Tong on 23/5/25.
//

import Flutter
import FlutterPluginRegistrant

class FViewController: FlutterViewController, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    private var cancels = Set<AnyCancellable>()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    deinit {
        print("FViewController deinit")
    }
    
    func dispose() {
        servicesChannel.setMethodCallHandler(nil)
        streamInChannel.setMessageHandler(nil)
        
        appServicesChannel.setMethodCallHandler(nil)
        appStreamOutChannel.setStreamHandler(nil)
        appStreamInChannel.setMessageHandler(nil)
        engine.destroyContext()
    }
    
    private lazy var streamInChannel: FlutterBasicMessageChannel = {
        return FManager.shared.makeStreamInChannel()
    }()
    
    private lazy var servicesChannel: FlutterMethodChannel = {
        return FManager.shared.makeServicesChannel()
    }()
    
    private lazy var appServicesChannel: FlutterMethodChannel = {
        return FlutterMethodChannel(
            name: "com.ziichat/app/services",
            binaryMessenger: engine.binaryMessenger
        )
    }()
    
    private lazy var appStreamOutChannel: FlutterEventChannel = {
        return FlutterEventChannel(
            name: "com.ziichat/app/stream/out",
            binaryMessenger: engine.binaryMessenger
        )
    }()
    
    private lazy var appStreamInChannel: FlutterBasicMessageChannel = {
        return FlutterBasicMessageChannel(
            name: "com.ziichat/app/stream/in",
            binaryMessenger: engine.binaryMessenger,
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appStreamOutChannel.setStreamHandler(self)
        
        servicesChannel.setMethodCallHandler { [weak self] call, result in
            self?.appServicesChannel.invokeMethod(call.method, arguments: call.arguments) { invokeResult in
                result(invokeResult)
            }
        }
        
        appServicesChannel.setMethodCallHandler { [weak self] call, result in
            self?.servicesChannel.invokeMethod(call.method, arguments: call.arguments) { invokeResult in
                result(invokeResult)
            }
        }
        
        appStreamInChannel.setMessageHandler { [weak self] message, reply in
            self?.streamInChannel.sendMessage(message)
            reply(nil)
        }
        
        FManager.shared.streamOut.sink { [weak self] message in
            self?.eventSink?(message)
        }
        .store(in: &cancels)
    }
}

import Combine
class FManager {
    
    static let shared = FManager()
    
    private let engines: FlutterEngineGroup
    private let servicesEngine: FlutterEngine
    
    let streamOut = PassthroughSubject<Any?, Never>()
    
    private init() {
        self.engines = FlutterEngineGroup(name: "com.ziichat", project: nil)
        self.servicesEngine = engines.makeEngine(withEntrypoint: "runServices", libraryURI: nil)
        GeneratedPluginRegistrant.register(with: servicesEngine)
    }
    
    func start() {
        let streamOutChannel = FlutterBasicMessageChannel(
            name: "com.ziichat/stream/out",
            binaryMessenger: servicesEngine.binaryMessenger,
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
        
        streamOutChannel.setMessageHandler { [weak streamOut] message, reply in
            streamOut?.send(message)
            reply(nil)
        }
    }
    
    func makeEngine(entryPoint: String? = nil) -> FlutterEngine {
        let engine = engines.makeEngine(withEntrypoint: entryPoint, libraryURI: nil)
        GeneratedPluginRegistrant.register(with: engine)
        return engine
    }
    
    func makeViewController() -> FViewController {
        return FViewController(engine: makeEngine(), nibName: nil, bundle: nil)
    }
    
    func makeServicesChannel() -> FlutterMethodChannel {
        return FlutterMethodChannel(
            name: "com.ziichat/services",
            binaryMessenger: servicesEngine.binaryMessenger
        )
    }
    
    func makeStreamInChannel() -> FlutterBasicMessageChannel {
        return FlutterBasicMessageChannel(
            name: "com.ziichat/stream/in",
            binaryMessenger: servicesEngine.binaryMessenger,
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
    }
}
