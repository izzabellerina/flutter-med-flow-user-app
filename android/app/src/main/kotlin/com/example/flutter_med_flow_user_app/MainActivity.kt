package com.example.flutter_med_flow_user_app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import com.acs.smartcard.Reader
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.flutter_med_flow_user_app/card_reader"
        private const val ACTION_USB_PERMISSION = "com.example.flutter_med_flow_user_app.USB_PERMISSION"
    }

    private var mReader: Reader? = null
    private var usbManager: UsbManager? = null
    private var currentDevice: UsbDevice? = null
    private var permissionGranted = false
    private var readerIsOpen = false
    private val readerLock = Object()
    private var isReading = false

    // APDU commands for Thai ID card
    private val selectCmd = byteArrayOf(
        0x00.toByte(), 0xA4.toByte(), 0x04.toByte(), 0x00.toByte(),
        0x08.toByte(), 0xA0.toByte(), 0x00.toByte(), 0x00.toByte(),
        0x00.toByte(), 0x54.toByte(), 0x48.toByte(), 0x00.toByte(), 0x01.toByte()
    )

    private val cidCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x00.toByte(), 0x04.toByte(), 0x02.toByte(), 0x00.toByte(), 0x0D.toByte())
    private val cidGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x0D.toByte())

    private val nameThCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x00.toByte(), 0x11.toByte(), 0x02.toByte(), 0x00.toByte(), 0x64.toByte())
    private val nameThGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x64.toByte())

    private val nameEnCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x00.toByte(), 0x75.toByte(), 0x02.toByte(), 0x00.toByte(), 0x64.toByte())
    private val nameEnGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x64.toByte())

    private val birthCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x00.toByte(), 0xD9.toByte(), 0x02.toByte(), 0x00.toByte(), 0x08.toByte())
    private val birthGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x08.toByte())

    private val genderCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x00.toByte(), 0xE1.toByte(), 0x02.toByte(), 0x00.toByte(), 0x01.toByte())
    private val genderGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x01.toByte())

    private val addressCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x15.toByte(), 0x79.toByte(), 0x02.toByte(), 0x00.toByte(), 0x64.toByte())
    private val addressGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x64.toByte())

    private val issueDateCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x01.toByte(), 0x67.toByte(), 0x02.toByte(), 0x00.toByte(), 0x08.toByte())
    private val issueDateGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x08.toByte())

    private val expireDateCmd = byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x01.toByte(), 0x6F.toByte(), 0x02.toByte(), 0x00.toByte(), 0x08.toByte())
    private val expireDateGet = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0x08.toByte())

    private val photoChunks = arrayOf(
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x01.toByte(), 0x7B.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x02.toByte(), 0x7A.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x03.toByte(), 0x79.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x04.toByte(), 0x78.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x05.toByte(), 0x77.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x06.toByte(), 0x76.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x07.toByte(), 0x75.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x08.toByte(), 0x74.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x09.toByte(), 0x73.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0A.toByte(), 0x72.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0B.toByte(), 0x71.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0C.toByte(), 0x70.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0D.toByte(), 0x6F.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0E.toByte(), 0x6E.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x0F.toByte(), 0x6D.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x10.toByte(), 0x6C.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x11.toByte(), 0x6B.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x12.toByte(), 0x6A.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x13.toByte(), 0x69.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte()),
        byteArrayOf(0x80.toByte(), 0xB0.toByte(), 0x14.toByte(), 0x68.toByte(), 0x02.toByte(), 0x00.toByte(), 0xFF.toByte())
    )
    private val photoGetData = byteArrayOf(0x00.toByte(), 0xC0.toByte(), 0x00.toByte(), 0x00.toByte(), 0xFF.toByte())

    private val usbPermissionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == ACTION_USB_PERMISSION) {
                val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                if (granted && device != null) {
                    currentDevice = device
                    permissionGranted = true
                    openReader(device)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        mReader = Reader(usbManager)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbPermissionReceiver, IntentFilter(ACTION_USB_PERMISSION), Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(usbPermissionReceiver, IntentFilter(ACTION_USB_PERMISSION))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkReaderAndRequestPermission" -> {
                    handleCheckAndRequestPermission(result)
                }
                "readAllCardData" -> {
                    try {
                        val data = readAllCardData()
                        result.success(data)
                    } catch (e: Exception) {
                        result.success(mapOf("error" to e.message))
                    }
                }
                "getCardStatus" -> {
                    handleGetCardStatus(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(usbPermissionReceiver)
        } catch (_: Exception) {}
        try {
            mReader?.close()
            readerIsOpen = false
        } catch (_: Exception) {}
        super.onDestroy()
    }

    private fun handleCheckAndRequestPermission(result: MethodChannel.Result) {
        val manager = usbManager ?: return result.success("NO_USB_MANAGER")
        val deviceList = manager.deviceList

        if (deviceList.isEmpty()) {
            return result.success("NO_READER")
        }

        // Find ACS reader (vendor ID 0x072F = 1839)
        var targetDevice: UsbDevice? = null
        for ((_, device) in deviceList) {
            if (device.vendorId == 1839) {
                targetDevice = device
                break
            }
        }

        if (targetDevice == null) {
            // Try any device
            targetDevice = deviceList.values.first()
        }

        currentDevice = targetDevice

        if (manager.hasPermission(targetDevice)) {
            permissionGranted = true
            openReader(targetDevice)
            result.success("PERMISSION_GRANTED")
        } else {
            val pendingIntent = PendingIntent.getBroadcast(
                this, 0,
                Intent(ACTION_USB_PERMISSION),
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            manager.requestPermission(targetDevice, pendingIntent)
            result.success("PERMISSION_REQUESTED")
        }
    }

    private fun handleGetCardStatus(result: MethodChannel.Result) {
        val manager = usbManager
        val status = HashMap<String, Any>()

        // Check reader connected
        var readerConnected = false
        var foundDevice: UsbDevice? = null
        if (manager != null) {
            val deviceList = manager.deviceList
            for ((_, device) in deviceList) {
                if (device.vendorId == 1839) {
                    readerConnected = true
                    foundDevice = device
                    break
                }
            }
        }

        if (!readerConnected) {
            if (readerIsOpen || currentDevice != null) {
                // USB reader was unplugged — reset state and recreate Reader
                try { mReader?.close() } catch (_: Exception) {}
                readerIsOpen = false
                currentDevice = null
                permissionGranted = false
                mReader = Reader(usbManager)
            }
        }

        if (readerConnected && foundDevice != null && manager != null) {
            if (manager.hasPermission(foundDevice) && !readerIsOpen) {
                // Reader plugged in with permission — open it
                currentDevice = foundDevice
                permissionGranted = true
                openReader(foundDevice)
            } else if (!manager.hasPermission(foundDevice)) {
                // Reader plugged in but no permission — request it
                val pendingIntent = PendingIntent.getBroadcast(
                    this, 0,
                    Intent(ACTION_USB_PERMISSION),
                    PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                manager.requestPermission(foundDevice, pendingIntent)
            }
        }

        // Check card inserted — skip if currently reading to avoid concurrent access
        var cardInserted = false
        val activeReader = mReader
        if (readerConnected && activeReader != null && readerIsOpen && !isReading) {
            try {
                synchronized(readerLock) {
                    val state = activeReader.getState(0)
                    cardInserted = state >= Reader.CARD_PRESENT
                }
            } catch (_: Exception) {
                // Reader state check failed — reader may be stale
                readerIsOpen = false
                currentDevice = null
            }
        }

        status["readerConnected"] = readerConnected
        status["cardInserted"] = cardInserted
        result.success(status)
    }

    private fun openReader(device: UsbDevice) {
        if (readerIsOpen) return
        val reader = mReader ?: return
        try {
            if (reader.isSupported(device)) {
                reader.open(device)
                readerIsOpen = true
            }
        } catch (_: Exception) {}
    }

    private fun readAllCardData(): Map<String, String> {
        val reader = mReader ?: throw Exception("Reader not initialized")
        val result = HashMap<String, String>()
        val resp = ByteArray(500)

        synchronized(readerLock) {
        isReading = true
        try {
            // Reset and select
            reader.power(0, Reader.CARD_WARM_RESET)
            reader.setProtocol(0, Reader.PROTOCOL_T0)
            reader.transmit(0, selectCmd, selectCmd.size, resp, resp.size)

            // CID
            reader.transmit(0, cidCmd, cidCmd.size, resp, resp.size)
            var len = reader.transmit(0, cidGet, cidGet.size, resp, resp.size)
            result["cid"] = bytesToHex(resp, len)

            // Thai name
            reader.transmit(0, nameThCmd, nameThCmd.size, resp, resp.size)
            len = reader.transmit(0, nameThGet, nameThGet.size, resp, resp.size)
            result["thaiName"] = bytesToTIS620(resp, len)

            // English name
            reader.transmit(0, nameEnCmd, nameEnCmd.size, resp, resp.size)
            len = reader.transmit(0, nameEnGet, nameEnGet.size, resp, resp.size)
            result["englishName"] = bytesToHex(resp, len)

            // Birth date
            reader.transmit(0, birthCmd, birthCmd.size, resp, resp.size)
            len = reader.transmit(0, birthGet, birthGet.size, resp, resp.size)
            result["birthDate"] = bytesToHex(resp, len)

            // Gender
            reader.transmit(0, genderCmd, genderCmd.size, resp, resp.size)
            len = reader.transmit(0, genderGet, genderGet.size, resp, resp.size)
            result["gender"] = bytesToHex(resp, len)

            // Address
            reader.transmit(0, addressCmd, addressCmd.size, resp, resp.size)
            len = reader.transmit(0, addressGet, addressGet.size, resp, resp.size)
            result["address"] = bytesToTIS620(resp, len)

            // Issue date
            reader.transmit(0, issueDateCmd, issueDateCmd.size, resp, resp.size)
            len = reader.transmit(0, issueDateGet, issueDateGet.size, resp, resp.size)
            result["issueDate"] = bytesToHex(resp, len)

            // Expire date
            reader.transmit(0, expireDateCmd, expireDateCmd.size, resp, resp.size)
            len = reader.transmit(0, expireDateGet, expireDateGet.size, resp, resp.size)
            result["expireDate"] = bytesToHex(resp, len)

            // Photo
            val photoBuffer = ByteArrayOutputStream()
            for (chunk in photoChunks) {
                reader.transmit(0, chunk, chunk.size, resp, resp.size)
                len = reader.transmit(0, photoGetData, photoGetData.size, resp, resp.size)
                if (len > 2) {
                    photoBuffer.write(resp, 0, len - 2)
                }
            }
            result["photo"] = bytesToHex(photoBuffer.toByteArray(), photoBuffer.size())

        } catch (e: Exception) {
            result["error"] = e.message ?: "Unknown error reading card"
        } finally {
            isReading = false
        }
        } // synchronized

        return result
    }

    private fun bytesToHex(bytes: ByteArray, length: Int): String {
        val actualLen = if (length > 2) length - 2 else length // Remove status word
        val sb = StringBuilder()
        for (i in 0 until actualLen) {
            sb.append(String.format("%02x", bytes[i]))
        }
        return sb.toString()
    }

    private fun bytesToTIS620(bytes: ByteArray, length: Int): String {
        val actualLen = if (length > 2) length - 2 else length
        val data = ByteArray(actualLen)
        System.arraycopy(bytes, 0, data, 0, actualLen)
        return String(data, Charset.forName("TIS620")).trim()
    }
}
