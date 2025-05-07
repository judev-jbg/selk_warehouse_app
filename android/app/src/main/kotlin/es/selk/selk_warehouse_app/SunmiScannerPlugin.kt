package com.selk.warehouse

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SunmiScannerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  // Constantes para las acciones del escáner Sunmi
  companion object {
    private const val SCANNER_ACTION = "com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED"
    private const val SCANNER_DATA = "data"
    private const val SCANNER_TYPE = "type"
    
    private const val METHOD_CHANNEL = "com.selk.warehouse/sunmi_scanner"
    private const val EVENT_CHANNEL = "com.selk.warehouse/sunmi_scanner_events"
  }

  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private var scanReceiver: BroadcastReceiver? = null
  private var eventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
    channel.setMethodCallHandler(this)
    
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> {
        result.success(true)
      }
      "startScan" -> {
        startScan(result)
      }
      "stopScan" -> {
        stopScan(result)
      }
      "configure" -> {
        configureScanner(call, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }
  
  private fun startScan(result: Result) {
    try {
      // En dispositivos Sunmi, normalmente se envía un intent específico para activar el escáner
      val intent = Intent("com.sunmi.scanner.ACTION_START_SCAN")
      context.sendBroadcast(intent)
      result.success(true)
    } catch (e: Exception) {
      result.error("START_SCAN_ERROR", "Error al iniciar el escáner: ${e.message}", null)
    }
  }
  
  private fun stopScan(result: Result) {
    try {
      val intent = Intent("com.sunmi.scanner.ACTION_STOP_SCAN")
      context.sendBroadcast(intent)
      result.success(true)
    } catch (e: Exception) {
      result.error("STOP_SCAN_ERROR", "Error al detener el escáner: ${e.message}", null)
    }
  }
  
  private fun configureScanner(call: MethodCall, result: Result) {
    try {
      // Configura el escáner según los parámetros recibidos
      // Ejemplo simple, en un caso real habría que implementar la configuración específica
      result.success(true)
    } catch (e: Exception) {
      result.error("CONFIGURE_ERROR", "Error al configurar el escáner: ${e.message}", null)
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    registerScanReceiver()
  }

  override fun onCancel(arguments: Any?) {
    unregisterScanReceiver()
    eventSink = null
  }
  
  private fun registerScanReceiver() {
    if (scanReceiver == null) {
      scanReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
          if (intent?.action == SCANNER_ACTION && eventSink != null) {
            // Procesa el resultado del escaneo
            val data = intent.getStringExtra(SCANNER_DATA) ?: return
            eventSink?.success(data)
          }
        }
      }
      
      val filter = IntentFilter().apply {
        addAction(SCANNER_ACTION)
      }
      
      context.registerReceiver(scanReceiver, filter)
    }
  }
  
  private fun unregisterScanReceiver() {
    if (scanReceiver != null) {
      context.unregisterReceiver(scanReceiver)
      scanReceiver = null
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    unregisterScanReceiver()
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }
}