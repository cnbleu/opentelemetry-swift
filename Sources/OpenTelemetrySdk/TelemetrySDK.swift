//
//  TelemetrySDK.swift
//  OpenTelemetrySdk
//
//  Created by gordon on 2021/8/16.
//

import Foundation
import OpenTelemetryApi
//import os.activity

@objc
@objcMembers
public class TelemetrySDK : NSObject {
    
    public static var instance = TelemetrySDK()
    
    private var _downgradeActiveSpan: TelemetrySpan?
    
    private override init() {
    }
    
//    @objc
//    public var activityIdent: os_activity_id_t {
//        return OpenTelemetrySDK.instance.contextProvider.getActivityIdent()
//    }
    
    @objc
    public func getTracer(_ instrumentationName: String) -> TelemetryTracer {
        return getTracer(instrumentationName, "")
    }

    @objc
    public func getTracer(_ instrumentationName: String, _ instrumentationVersion: String) -> TelemetryTracer {
        return TelemetryTracer(tracer: OpenTelemetrySDK.instance.tracerProvider.get(instrumentationName: instrumentationName, instrumentationVersion: instrumentationVersion))
    }
    
    @objc
    public func addSpanProcessor(_ spanExporter: TelemetrySpanExporter) {
        OpenTelemetrySDK.instance.tracerProvider.addSpanProcessor(SimpleSpanProcessor(spanExporter: BridgeSpanExporter(exporter: spanExporter)))
    }

    @objc
    public func updateActiveResource(_ resource: TelemetryResource) {
        OpenTelemetrySDK.instance.tracerProvider.updateActiveResource(resource.resource)
    }

    @objc
    public func activeResource() -> TelemetryResource {
        return TelemetryResource.init(resource: OpenTelemetrySDK.instance.tracerProvider.getActiveResource())
    }
    
    @objc
    public func activeSpan() -> TelemetrySpan? {
        let span: Span? = OpenTelemetrySDK.instance.contextProvider.activeSpan
        if span != nil {
            return TelemetrySpan(span: span!)
        } else {
            return nil
        }
    }
    
    @objc
    public func setActiveSpan(_ span: TelemetrySpan) {
        OpenTelemetrySDK.instance.contextProvider.setActiveSpan(span.span)
    }
    
    @objc
    public func downgradeActiveSpan() -> TelemetrySpan? {
        return self._downgradeActiveSpan
    }
    
    @objc
    public func setDowngradeActiveSpan(_ span: TelemetrySpan) {
        self._downgradeActiveSpan = span
    }
    
    @objc
    public func removeContextForSpan(_ span: TelemetrySpan) {
        OpenTelemetrySDK.instance.contextProvider.removeContextForSpan(span.span);
    }
    
    @objc
    public func activeTextMapPropagator() -> TelemetryTextMapPropagator {
        return TelemetryTextMapPropagator(textMapPropagator: OpenTelemetrySDK.instance.propagators.textMapPropagator)
    }
    
    @objc
    public func test(tst: String) {
        print("test" + tst)
    }
}

@objc
public class TelemetryTracer : NSObject {
    private var tracer: Tracer
    
    public init(tracer: Tracer) {
        self.tracer = tracer
    }
    
    @objc
    public func spanBuilder(spanName: String) -> TelemetrySpanBuilder {
        return TelemetrySpanBuilder(tracer: self.tracer, spanBuilder: self.tracer.spanBuilder(spanName: spanName))
    }
    
}

@objc
public class TelemetrySpanBuilder: NSObject {
    private var spanBuilder: SpanBuilder
    private var telemetrySpan: TelemetrySpan?
    private var tracer: Tracer
    
    fileprivate init(tracer: Tracer, spanBuilder: SpanBuilder) {
        self.tracer = tracer
        self.spanBuilder = spanBuilder
    }
    
    @objc
    public func setParent(_ parent: TelemetrySpan) -> Self {
        self.spanBuilder.setParent(parent.span)
        return self
    }
    
    @objc
    public func setParentWithContext(_ parent: TelemetrySpanContext) -> Self {
        return self
    }
    
    @objc
    public func setNoParent() -> Self {
        spanBuilder.setNoParent()
        return self
    }
    
    @objc
    public func addLink(spanContext: TelemetrySpanContext) -> Self {
        return self
    }
    
    @objc
    public func addLink(spanContext: TelemetrySpanContext, attributes: [String: TelemetryAttributeValue]) -> Self {
        return self
    }
    
    @objc
    public func setAttribute(key: String, stringValue: String) -> Self {
        spanBuilder.setAttribute(key: key, value: stringValue)
        return self
    }
    
    @objc
    public func setAttribute(key: String, intValue: Int) -> Self {
        spanBuilder.setAttribute(key: key, value: intValue)
        return self
    }
    
    @objc
    public func setAttribute(key: String, doubleValue: Double) -> Self {
        spanBuilder.setAttribute(key: key, value: doubleValue)
        return self
    }
    
    @objc
    public func setAttribute(key: String, boolValue: Bool) -> Self {
        spanBuilder.setAttribute(key: key, value: boolValue)
        return self
    }
    
    @objc
    public func setAttribute(key: String, attributeValue: TelemetryAttributeValue) -> Self {
        spanBuilder.setAttribute(key: key, value: attributeValue.attribute)
        return self
    }
    
    @objc
    public func setSpanKind(spanKind: TelemetrySpanKind) -> Self {
        spanBuilder.setSpanKind(spanKind: spanKind.kind)
        return self
    }
    
    @objc
    public func setStartTime(time: NSDate) -> Self {
        spanBuilder.setStartTime(time: Date(timeIntervalSince1970: time.timeIntervalSince1970))
        return self
    }
    
    @objc
    public func startSpan() -> TelemetrySpan? {
        let span = spanBuilder.startSpan()
        return TelemetrySpan(span: span)
    }
}

@objc
@objcMembers
public class TelemetrySpan: NSObject {
    fileprivate var span: Span
    
    fileprivate init(span: Span) {
        self.span = span
    }
    
    public var kind: TelemetrySpanKind {
        return TelemetrySpanKind(span.kind)
    }
    
    public var context: TelemetrySpanContext {
        return TelemetrySpanContext(spanContext: span.context)
    }
    
    public var isRecording: Bool {
        return span.isRecording
    }
    
    public var status: TelemetryStatus {
        return TelemetryStatus(span.status)
    }
    
    public var name: String {
        return span.name
    }
    
    @objc
    public func setAttribute(key: String, value: TelemetryAttributeValue?) {
        span.setAttribute(key: key, value: value?.attribute)
    }
    
    @objc
    public func addEvent(name: String) {
        span.addEvent(name: name);
    }
    
    @objc
    public func addEvent(name: String, timestamp: NSDate) {
        span.addEvent(name: name, timestamp: Date(timeIntervalSince1970: timestamp.timeIntervalSince1970))
    }
    
    @objc
    public func addEvent(name: String, attributes: [String: TelemetryAttributeValue], timestamp: NSDate) {
        var attr: [String: AttributeValue] = [String: AttributeValue]()
        for kv in attributes {
            attr.updateValue(kv.value.attribute, forKey: kv.key)
        }
        
        span.addEvent(name: name, attributes: attr, timestamp: Date(timeIntervalSince1970: timestamp.timeIntervalSince1970))
    }
    
    @objc
    public func end() {
        span.end()
    }
    
    @objc
    public func end(time: NSDate) {
        span.end(time: Date(timeIntervalSince1970: time.timeIntervalSince1970))
    }
}


@objc
@objcMembers
public class TelemetrySpanContext: NSObject {
    fileprivate var spanContext: SpanContext
    
    fileprivate init(spanContext: SpanContext) {
        self.spanContext = spanContext
    }
    
    public var traceId: String {
        return spanContext.traceId.hexString
    }
    
    public var spanId: String {
        return spanContext.spanId.hexString
    }
    
    public var isRemote: Bool {
        return spanContext.isRemote
    }
}

@objc
@objcMembers
public class TelemetryAttributeValue: NSObject {
    fileprivate var attribute: AttributeValue
    
    public var value: String
    
    fileprivate init(attribute: AttributeValue) {
        self.attribute = attribute
        self.value = String(attribute.description)
//        switch attribute {
//        case let .string(value):
//            self.value = value
//        case let .bool(value):
//            self.value = value ? "true" : "false"
//        case let .int(value):
//            self.value = String(value)
//        case let .double(value):
//            self.value = String(value)
//
//        }
    }
    
    @objc
    public convenience init(stringValue: String) {
        self.init(attribute: AttributeValue.string(stringValue))
    }
    
    @objc
    public convenience init(boolValue: Bool) {
        self.init(attribute: AttributeValue.bool(boolValue))
    }
    
    @objc
    public convenience init(intValue: Int) {
        self.init(attribute: AttributeValue.int(intValue))
    }
    
    @objc
    public convenience init(doubleValue: Double) {
        self.init(attribute: AttributeValue.double(doubleValue))
    }
}

@objc
@objcMembers
public class TelemetrySpanKind: NSObject {
    fileprivate var kind: SpanKind

    public static var INTERNAL: TelemetrySpanKind {
        return TelemetrySpanKind(SpanKind.internal)
    }
    
    public static  var SERVER: TelemetrySpanKind {
        return TelemetrySpanKind(SpanKind.server)
    }
    
    public static var CLIENT: TelemetrySpanKind {
        return TelemetrySpanKind(SpanKind.client)
    }
    
    public static var PRODUCER: TelemetrySpanKind {
        return TelemetrySpanKind(SpanKind.producer)
    }
    
    public static var CONSUMER: TelemetrySpanKind {
        return TelemetrySpanKind(SpanKind.consumer)
    }
    
    public var name: String
    
    fileprivate init(_ kind: SpanKind) {
        self.kind = kind

        switch kind {
        case .internal:
            name = "internal"
        case .server:
            name = "server"
        case .client:
            name = "client"
        case .producer:
            name = "producer"
        case .consumer:
            name = "consumer"
        }
    }

    fileprivate convenience init(_ name: String) {
        switch name {
        case "internal":
            self.init(.internal)
        case "server":
            self.init(.server)
        case "client":
            self.init(.client)
        case "producer":
            self.init(.producer)
        case "consumer":
            self.init(.consumer)
        default:
            self.init(.internal)
        }
    }
    
}

@objc
@objcMembers
public class TelemetryStatus: NSObject {
    private var status: Status
    public var name: String
    
    public static var OK: TelemetryStatus {
        return TelemetryStatus(.ok)
    }
    
    public static var ERROR: TelemetryStatus {
        return TelemetryStatus(.error(description: "error"))
    }
    
    public static var UNSET: TelemetryStatus {
        return TelemetryStatus(.unset)
    }
    
    fileprivate init(_ status: Status) {
        self.status = status
        
        switch status {
        case .ok:
            name = "ok"
        case .error(description: _):
            name = "error"
        default:
            name = "unset"
        }
    }
    
    fileprivate convenience init(_ name: String) {
        switch name {
        case "ok":
            self.init(.ok)
        case "error":
            self.init(.error(description: ""))
        default:
            self.init(.unset)
        }
    }
}

@objc
public class TelemetrySpanProcessor: NSObject {
    private var spanProcessor: SpanProcessor
    public init(spanProcessor: SpanProcessor) {
        self.spanProcessor = spanProcessor
    }
}


@objc(TelemetrySpanExporter)
public protocol TelemetrySpanExporter: NSObjectProtocol {
    
    func exportTelemetrySpan(spans: [TelemetrySpanData]) -> TelemetrySpanExporterResultCode
    
    func flushTelemetrySpan() -> TelemetrySpanExporterResultCode
    
    func shudownTelemetrySpan()
    
}

@objc
@objcMembers
public class TelemetrySpanData: NSObject {
    private var spanData: SpanData
    
    public init(spanData: SpanData) {
        self.spanData = spanData
    }
    
    public var traceId: String {
        return spanData.traceId.hexString;
    }
    
    public var spanId: String {
        return spanData.spanId.hexString;
    }
    
    // traceFlags
    
    // traceState
    
    public var parentSpanId: String? {
        return spanData.parentSpanId?.hexString;
    }
    
    public var resource: TelemetryResource {
        return TelemetryResource(resource: spanData.resource)
    }

    // instrumentationLibraryInfo
    
    public var name: String {
        return spanData.name;
    }
    
    public var kind: TelemetrySpanKind {
        return TelemetrySpanKind(spanData.kind)
    }
    
    public var startTime: NSDate {
        return NSDate(timeIntervalSince1970: spanData.startTime.timeIntervalSince1970)
    }
    
    public var attributes: [String: TelemetryAttributeValue] {
        var attr: [String: TelemetryAttributeValue] = [String: TelemetryAttributeValue]()
        for kv in spanData.attributes {
            attr.updateValue(TelemetryAttributeValue(attribute: kv.value), forKey: kv.key)
        }
        
        return attr
    }
    
    public var events: [TelemetryEvent] {
        var evts: [TelemetryEvent] = [TelemetryEvent]()
        
        for event in spanData.events {
            evts.append(TelemetryEvent(event))
        }
        
        return evts
    }
    
    public var links: [TelemetryLink] {
        var links: [TelemetryLink] = [TelemetryLink]()
        
        for kv in spanData.links {
            links.append(TelemetryLink(kv))
        }
        return links
    }
    
    public var status: TelemetryStatus {
        return TelemetryStatus(spanData.status)
    }
    
    public var endTime: NSDate {
        return NSDate(timeIntervalSince1970: spanData.endTime.timeIntervalSince1970)
    }
    
    public var hasRemoteParent: Bool {
        return spanData.hasRemoteParent
    }
    
    public var hasEnded: Bool {
        return spanData.hasEnded
    }
    
    public var totalRecordedEvents: Int {
        return spanData.totalRecordedEvents
    }
    
    public var totalRecordedLinks: Int {
        return spanData.totalRecordedLinks
    }
    
    public var totalAttributeCount: Int {
        return spanData.totalAttributeCount
    }
    
}

@objc
@objcMembers
public class TelemetryLink: NSObject {
    private var link: SpanData.Link
    
    public var context: TelemetrySpanContext {
        return TelemetrySpanContext(spanContext: link.context)
    }
    
    public var attributes: [String: TelemetryAttributeValue] {
        var attr: [String: TelemetryAttributeValue] = [String: TelemetryAttributeValue]()
        for kv in link.attributes {
            attr.updateValue(TelemetryAttributeValue(attribute: kv.value), forKey: kv.key)
        }
        
        return attr
    }
    
    fileprivate init(_ link: SpanData.Link) {
        self.link = link
    }
}

@objc
@objcMembers
public class TelemetryEvent: NSObject {
    private var event: SpanData.Event
    
    public init(_ event: SpanData.Event) {
        self.event = event
    }
    
    @objc
    public convenience init(_ name: String, timestamp: NSDate) {
        let event: SpanData.Event = SpanData.Event(name: name, timestamp: Date(timeIntervalSince1970: timestamp.timeIntervalSince1970))
        self.init(event)
    }
    
    
    public var timestamp: NSDate {
        return NSDate(timeIntervalSince1970: event.timestamp.timeIntervalSince1970)
    }
    
    public var name: String {
        return event.name
    }
    
    public var attributes: [String: TelemetryAttributeValue] {
        var attr: [String: TelemetryAttributeValue] = [String: TelemetryAttributeValue]()
        
        for kv in event.attributes {
            attr.updateValue(TelemetryAttributeValue(attribute: kv.value), forKey: kv.key)
        }

        return attr
    }
}

@objc
@objcMembers
public class TelemetryResource: NSObject {
    fileprivate var resource: Resource;
    
    public var attributes: [String: TelemetryAttributeValue] {
        var attr: [String: TelemetryAttributeValue] = [String: TelemetryAttributeValue]()
        for kv in resource.attributes {
            attr.updateValue(TelemetryAttributeValue(attribute: kv.value), forKey: kv.key)
        }
        return attr
    }
    
    fileprivate init(resource: Resource) {
        self.resource = resource;
    }
    
    @objc
    public convenience init(attributes: [String: TelemetryAttributeValue]) {
        var attr: [String: AttributeValue] = [String: AttributeValue]()
        for kv in attributes {
            attr.updateValue(kv.value.attribute, forKey: kv.key)
        }
        
        self.init(resource: Resource(attributes: attr))
    }
    
    @objc
    public static var empty: TelemetryResource {
        return TelemetryResource(resource: Resource.empty)
    }
    
    @objc
    public func merge(other: TelemetryResource) {
        resource.merge(other: other.resource)
    }
    
    @objc
    public func merging(other: TelemetryResource) -> TelemetryResource{
        return TelemetryResource(resource: resource.merging(other: other.resource))
    }
}


@objc
@objcMembers
public class TelemetrySpanExporterResultCode: NSObject {
    fileprivate var resultCode: SpanExporterResultCode
    public var code: String
    
    public static var SUCCESS: TelemetrySpanExporterResultCode {
        return TelemetrySpanExporterResultCode(resultCode: SpanExporterResultCode.success)
    }
    
    public static var FAILURE: TelemetrySpanExporterResultCode {
        return TelemetrySpanExporterResultCode(resultCode: SpanExporterResultCode.failure)
    }
    
    public init(resultCode: SpanExporterResultCode) {
        self.resultCode = resultCode
        if (.success == resultCode) {
            code = "success"
        } else {
            code = "failure"
        }
    }
    
    @objc
    public convenience init(_ code: String) {
        if ("success" == code) {
            self.init(resultCode: .success)
        } else {
            self.init(resultCode: .failure)
        }
    }
}

@objc
@objcMembers
public class TelemetryTextMapPropagator: NSObject {
    fileprivate var textMapPropagator: TextMapPropagator
    
    public init(textMapPropagator: TextMapPropagator) {
        self.textMapPropagator = textMapPropagator
    }
    
    @objc
    public func inject(_ context: TelemetrySpanContext, _ carrier: NSMutableDictionary, _ setter: TelemetrySetter) {
        var carrierLocal = [String: String]()
        textMapPropagator.inject(spanContext: context.spanContext, carrier: &carrierLocal, setter: BridgeTelemetrySetter(setter: setter, carrier: carrier))
    }
}

@objc(TelemetrySetter)
public protocol TelemetrySetter: NSObjectProtocol {
    
    func set(_ dict: NSMutableDictionary, _ key: String, _ value: String)
}

public class BridgeTelemetrySetter: NSObject, Setter {
    private var setter: TelemetrySetter
    private var bridgeCarrier: NSMutableDictionary
    
    public init(setter: TelemetrySetter, carrier: NSMutableDictionary) {
        self.setter = setter
        self.bridgeCarrier = carrier
    }
    
    public func set(carrier: inout [String : String], key: String, value: String) {
        self.setter.set(bridgeCarrier, key, value)
    }
}

public class BridgeSpanExporter: NSObject, SpanExporter, TelemetrySpanExporter {
    private var exporter: TelemetrySpanExporter
    
    public init(exporter: TelemetrySpanExporter) {
        self.exporter = exporter;
    }
    
    
    public func export(spans: [SpanData]) -> SpanExporterResultCode {
        var telemetrySpanData = [TelemetrySpanData]()

        for span in spans {
            telemetrySpanData.append(TelemetrySpanData(spanData: span))
        }
        
        return exportTelemetrySpan(spans: telemetrySpanData).resultCode
    }

    ///Exports the collection of sampled Spans that have not yet been exported.
    public func flush() -> SpanExporterResultCode {
        return flushTelemetrySpan().resultCode
    }
    
    /// Called when TracerSdkFactory.shutdown()} is called, if this SpanExporter is registered
    ///  to a TracerSdkFactory object.
    public func shutdown() {
        self.shudownTelemetrySpan()
    }
    
    public func exportTelemetrySpan(spans: [TelemetrySpanData]) -> TelemetrySpanExporterResultCode {
        return self.exporter.exportTelemetrySpan(spans: spans)
    }
    
    public func flushTelemetrySpan() -> TelemetrySpanExporterResultCode {
        return self.exporter.flushTelemetrySpan()
    }
    
    public func shudownTelemetrySpan() {
        self.exporter.shudownTelemetrySpan()
    }
}
