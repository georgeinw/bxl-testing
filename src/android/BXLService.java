package com.bxl.service.phonegap;

import jpos.JposException;
import jpos.POSPrinter;
import jpos.config.JposEntry;
import jpos.POSPrinterConst;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import com.bxl.config.editor.BXLConfigLoader;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import jpos.events.OutputCompleteEvent;
import jpos.events.OutputCompleteListener;

import com.bxl.config.util.BXLNetwork;

public class BXLService extends CordovaPlugin implements OutputCompleteListener{

    private static final String TAG = BXLService.class.getSimpleName();
    private final boolean DEBUG = true;

    public static final String DEVICE_ADDRESS_START = " (";
    public static final String DEVICE_ADDRESS_END = ")";

    private final String ACTION_EXECUTE_PRINTER = "executePrinter";

    // printer open/close
    private final String METHOD_ADD_ENTRY = "addEntry";
    private final String METHOD_GET_PAIRED_DEVICE = "getPairedDevice";
    private final String METHOD_GET_NETWORK_DEVICE = "getNetworkDevice";
    private final String METHOD_OPEN = "open";
    private final String METHOD_CLAIM = "claim";
    private final String METHOD_SET_DEVICE_ENABLED = "setDeviceEnabled";
    private final String METHOD_RELEASE = "release";
    private final String METHOD_CLOSE = "close";
    
    // page mode
    private final String METHOD_PAGE_MODE_PRINT = "pageModePrint";
    private final String METHOD_SET_PAGE_MODE_PRINT_AREA = "setPageModePrintArea";
    private final String METHOD_SET_PAGE_MODE_PRINT_DIRECTION = "setPageModePrintDirection";
    private final String METHOD_SET_PAGE_MODE_HORIZONTAL_POSITION = "setPageModeHorizontalPosition";
    private final String METHOD_SET_PAGE_MODE_VERTICAL_POSITION = "setPageModeVerticalPosition";

    // print : text, barcode, image..
    private final String METHOD_PRINT_BAR_CODE = "printBarCode";
    private final String METHOD_PRINT_BITMAP_WITH_URL = "printBitmapWithURL";
    private final String METHOD_PRINT_BITMAP_WITH_BASE64 = "printBitmapWithBase64";
    private final String METHOD_PRINT_NORMAL = "printNormal";
    private final String METHOD_TRANSACTION_PRINT = "transactionPrint";

    // other func
    private final String METHOD_CUT_PAPER = "cutPaper";
    private final String METHOD_MARK_FFED = "markFeed";
    private final String METHOD_SET_CHARACTER_SET = "setCharacterSet";
    private final String METHOD_GET_PRINTER_STATUS = "getPrinterStatus";
    private final String METHOD_DIRECT_IO = "directIO";

    // Event
    private final String METHOD_SET_OUTPUT_COMPLETE_EVENT = "outputCompleteEvent";
    private CallbackContext outputCompleteCallback = null;

    private static POSPrinter posPrinter;

    BluetoothAdapter mBTAdapter;
    Set<BluetoothDevice> pairedDevices;

    private static BXLConfigLoader bxlConfigLoader = null;

    private String mAddress = "";

    public static void setContext(Context context) {
        if (bxlConfigLoader == null) {
            bxlConfigLoader = new BXLConfigLoader(context);
        }

        posPrinter = new POSPrinter(context);
    }

    @Override
    public void pluginInitialize() {
        this.setContext(webView.getContext());
        posPrinter.addOutputCompleteListener(this);
    }


    /**
     * image url을 받아서 bitmap을 생성하고 리턴합니다
     *
     * @param url
     *            얻고자 하는 image url
     * @return 생성된 bitmap
     */

    /**
     * image url을 받아서 bitmap을 생성하고 리턴합니다
     *
     * @param url
     *            얻고자 하는 image url
     * @return 생성된 bitmap
     */
    private Bitmap getBitmap(String url) {
        URL imgUrl = null;
        HttpURLConnection connection = null;
        InputStream is = null;

        Bitmap retBitmap = null;

        try {
            imgUrl = new URL(url);
            connection = (HttpURLConnection) imgUrl.openConnection();
            connection.setDoInput(true); // url로 input받는 flag 허용
            connection.connect(); // 연결
            is = connection.getInputStream(); // get inputstream
            retBitmap = BitmapFactory.decodeStream(is);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
            return retBitmap;
        }
    }



    /**
     * image url을 받아서 bitmap을 생성하고 리턴합니다
     *
     * @param url
     *            얻고자 하는 image url
     * @return 생성된 bitmap
     */

    /**
     * base 64로 encoding 된 image data을 받아서 bitmap을 생성하고 리턴합니다
     *
     * @param base64EncodedData
     *            얻고자 하는 image url
     * @return 생성된 bitmap
     */
    private Bitmap getDecodedBitmap(String base64EncodedData) {

        byte[] imageAtBytes = Base64.decode(base64EncodedData.getBytes(), Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(imageAtBytes, 0, imageAtBytes.length);
    }

	public static Set<BluetoothDevice> getPairedDevices() throws IllegalStateException
	{
        String ADDRESS_PREFIX = "74:F0:7D";
		BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

		if(bluetoothAdapter == null)
		{
			throw new IllegalStateException("Bluetooth is not available.");
		}

		if(!bluetoothAdapter.isEnabled())
		{
			throw new IllegalStateException("Bluetooth is not enabled.");
		}

		Set<BluetoothDevice> bondedDevices = bluetoothAdapter.getBondedDevices();
		Set<BluetoothDevice> pairedDevices = new HashSet<BluetoothDevice>();

		for(BluetoothDevice device:bondedDevices)
		{
			if(device.getAddress().startsWith(ADDRESS_PREFIX))
			{
				pairedDevices.add(device);
			}
		}

		if(pairedDevices.size() > 0)
		{
			return Collections.unmodifiableSet(pairedDevices);
		}
		else
		{
			return null;
		}
	}


    /**
     * Executes the request.
     *
     * This method is called from the WebView thread. To do a non-trivial amount
     * of work, use: cordova.getThreadPool().execute(runnable);
     *
     * To run on the UI thread, use:
     * cordova.getActivity().runOnUiThread(runnable);
     *
     * @param action
     *            The action to execute.
     * @param args
     *            The exec() arguments.
     * @param callbackContext
     *            The callback context used when calling back into JavaScript.
     * @return Whether the action was valid.
     */
    @Override
    public boolean execute(final String action, final JSONArray args,
                           final CallbackContext callbackContext) throws JSONException {
        if (DEBUG) {
            Log.d(TAG, "execute(" + action + ", " + args + ", "
                    + callbackContext + ")");
        }

        if (!action.equals(ACTION_EXECUTE_PRINTER)) {
            callbackContext.error("Action is not matched");
            return false;
        }

        String method = args.getString(0);
        try {
            if (method.equals(METHOD_SET_DEVICE_ENABLED)) {
                posPrinter.setDeviceEnabled(args.getBoolean(1));
                callbackContext.success();
            } else if (method.equals(METHOD_SET_CHARACTER_SET)) {
                posPrinter.setCharacterSet(args.getInt(1));
                callbackContext.success();
            } else if (method.equals(METHOD_SET_PAGE_MODE_HORIZONTAL_POSITION)) {
                posPrinter.setPageModeHorizontalPosition(args.getInt(1));
                callbackContext.success();
            } else if (method.equals(METHOD_SET_PAGE_MODE_PRINT_AREA)) {
                String area = args.getString(1);
                area = area.substring(1, area.length() - 1);
                area = area.replace(" ", "");
                posPrinter.setPageModePrintArea(area);
                callbackContext.success();
            } else if (method.equals(METHOD_SET_PAGE_MODE_PRINT_DIRECTION)) {
                int arg1 = args.getInt(1);
                int direction = POSPrinterConst.PTR_PD_LEFT_TO_RIGHT;

                switch(arg1)
                {
                    case 0:     direction = POSPrinterConst.PTR_PD_LEFT_TO_RIGHT;   break;
                    case 1:     direction = POSPrinterConst.PTR_PD_BOTTOM_TO_TOP;   break;
                    case 2:     direction = POSPrinterConst.PTR_PD_RIGHT_TO_LEFT;   break;
                    case 3:     direction = POSPrinterConst.PTR_PD_TOP_TO_BOTTOM;   break;
                }

                posPrinter.setPageModePrintDirection(direction);
                callbackContext.success();
            } else if (method.equals(METHOD_SET_PAGE_MODE_VERTICAL_POSITION)) {
                posPrinter.setPageModeVerticalPosition(args.getInt(1));
                callbackContext.success();
            } else if (method.equals(METHOD_OPEN)) {
                posPrinter.open(args.getString(1));
                callbackContext.success();
            } else if (method.equals(METHOD_CLOSE)) {
                posPrinter.close();
                callbackContext.success();
            } else if (method.equals(METHOD_CLAIM)) {
                posPrinter.claim(args.getInt(1));
                posPrinter.setAsyncMode(true);
                callbackContext.success();
            } else if (method.equals(METHOD_RELEASE)) {
                posPrinter.release();
                callbackContext.success();
            } else if (method.equals(METHOD_CUT_PAPER)) {
                posPrinter.cutPaper(args.getInt(1));
                callbackContext.success();
            } else if (method.equals(METHOD_MARK_FFED)) {
                posPrinter.markFeed(args.getInt(1));
                callbackContext.success();
            } else if (method.equals(METHOD_PAGE_MODE_PRINT)) {
                int mode = (args.getInt(1) == 1) ? POSPrinterConst.PTR_PM_PAGE_MODE : POSPrinterConst.PTR_PM_NORMAL;
                posPrinter.pageModePrint(mode);
                callbackContext.success();
            } else if (method.equals(METHOD_PRINT_BAR_CODE)) {
                posPrinter.printBarCode(args.getInt(1), args.getString(2),
                        args.getInt(3), args.getInt(4), args.getInt(5),
                        args.getInt(6), args.getInt(7));
                callbackContext.success();
            } else if (method.equals(METHOD_PRINT_BITMAP_WITH_URL)) {
                // BitmapDrawable bmpDrawAble = (BitmapDrawable)
                // context.getResources().getDrawable(R.drawable.sample);
                // Bitmap image = bmpDrawAble.getBitmap();
                String imageURL = args.getString(2);
                Bitmap image = getBitmap(imageURL);
                ByteBuffer bitmapbuffer = ByteBuffer.allocate(4);
                bitmapbuffer.put((byte) args.getInt(1));
                bitmapbuffer.put((byte) 80);
                bitmapbuffer.put((byte) 0x00);
                bitmapbuffer.put((byte) 0x00);

                posPrinter.printBitmap(bitmapbuffer.getInt(0), image, args.getInt(3), args.getInt(4));
                callbackContext.success();
            }else if (method.equals(METHOD_PRINT_BITMAP_WITH_BASE64)) {
                // BitmapDrawable bmpDrawAble = (BitmapDrawable)
                // context.getResources().getDrawable(R.drawable.sample);
                // Bitmap image = bmpDrawAble.getBitmap();
                String base64EncodedData= args.getString(2);
                Bitmap image = getDecodedBitmap(base64EncodedData); //getBitmap(imageURL);
                ByteBuffer bitmapbuffer = ByteBuffer.allocate(4);
                bitmapbuffer.put((byte) args.getInt(1));
                bitmapbuffer.put((byte) 80);
                bitmapbuffer.put((byte) 0x00);
                bitmapbuffer.put((byte) 0x00);

                posPrinter.printBitmap(bitmapbuffer.getInt(0), image, args.getInt(3), args.getInt(4));
                callbackContext.success();
            } else if (method.equals(METHOD_PRINT_NORMAL)) {
                posPrinter.printNormal(args.getInt(1), args.getString(2));
                callbackContext.success();
            } else if (method.equals(METHOD_TRANSACTION_PRINT)) {
                posPrinter.transactionPrint(args.getInt(1), args.getInt(2));
                callbackContext.success();
            } else if (method.equals(METHOD_DIRECT_IO)) {
                String stringData = args.getString(1);
                String[] arrayData;
                byte[] data;
                stringData = stringData.substring(1, stringData.length() - 1);
                arrayData = stringData.split(",");

                data = new byte[arrayData.length];
                for(int i = 0; i < arrayData.length; i++)   data[i] = (byte)(Integer.parseInt(arrayData[i]));
                posPrinter.directIO(1, null, data);
                callbackContext.success();
            } else if(method.equals(METHOD_GET_PRINTER_STATUS)){
                int status = posPrinter.getPrinterStatus();
                // Cover open or paper empty is detected, reset OFFLINE bit.
                if((status & 1) != 0) status &= ~32;
                if((status & 2) != 0) status &= ~32;
                // Over open and paper empty are detected, reset paper empty bit.
                if((status & 1) != 0 && (status & 2) != 0) status &= ~2;
                callbackContext.success(status);
            }else if (method.equals(METHOD_ADD_ENTRY)) {
                ///////////////////////////////

                try {
//					JSONArray args = objs.getJSONArray("data");
                    String productName = args.getString(1);
                    String categoryType = "2";//args.getString(2);
                    String ifType = args.getString(2);
                    String address = args.getString(3);
                    String ldn = null;
                    if (args.length() > 4)
                        ldn = args.getString(4);

                    if (productName == null || categoryType == null || ifType == null || address == null
                            || productName.length() <= 0 || categoryType.length() <= 0 || ifType.length() <= 0
                            || address.length() <= 0) {


                        callbackContext.error("Argument Error");
                    }

                    try {
                        bxlConfigLoader.openFile();
                    } catch (Exception e) {
                        bxlConfigLoader.newFile();
                    }

                    for (Object entry : bxlConfigLoader.getEntries()) {
                        JposEntry jposEntry = (JposEntry) entry;
                        bxlConfigLoader.removeEntry(jposEntry.getLogicalName());
                    }

                    bxlConfigLoader.addEntry((ldn == null || ldn.length() <= 0) ? productName : ldn,
                            Integer.parseInt(categoryType),
                            getProductName(productName),
                            Integer.parseInt(ifType),
                            address);

                    bxlConfigLoader.saveFile();

                } catch (JSONException e) {
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                } catch (Exception e) {
                    e.printStackTrace();
                    e.printStackTrace();
                    callbackContext.error(e.getMessage());
                }
                ///////////////////////////////
                callbackContext.success();
            }else if(method.equals(METHOD_GET_PAIRED_DEVICE)){
                Set<BluetoothDevice> bluetoothDeviceSet = getPairedDevices();
                if(bluetoothDeviceSet != null)
                {
                		String listArr = "";
                		String obj = "";
                		for(BluetoothDevice device:bluetoothDeviceSet)
										{
											obj = "";
											obj += "{\"address\": ";
			                obj += "\"";
			                obj += device.getAddress();
			                obj += "\",";
			
			                obj += "\"modelName\": ";
			                obj += "\"";
			                obj += device.getName();
			                obj += "\"},";
											
											listArr += obj;
										}
										
										listArr = listArr.substring(0, listArr.length() - 1);
                    //DialogManager.showBluetoothDialog(this.cordova.getActivity(), bluetoothDeviceSet);
                    callbackContext.success(listArr);
                }
                else
                {
                	  callbackContext.error("Not found paired devices.");
                      return false;
                }
            }else if(method.equals(METHOD_GET_NETWORK_DEVICE)){
                boolean wire = args.getBoolean(1);
                int timeout = args.getInt(2);
                byte option = (wire) ? (byte)0x01 : (byte)0x02;

                BXLNetwork.setWifiSearchOption(timeout, 1, option);
                String networkPrinter = BXLNetwork.getNetworkPrinters();
                callbackContext.success(networkPrinter);
            }else if(method.equals(METHOD_SET_OUTPUT_COMPLETE_EVENT)){
                outputCompleteCallback = callbackContext;
            }else {
                callbackContext.error("Requested function is not defined.");
                return false;
            }

            return true;
        } catch (JposException e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
            return false;
        } catch (JSONException e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
            return false;
        }
        catch(IllegalStateException e){
            e.printStackTrace();
            callbackContext.error(e.getMessage());
            return false;
        }
    }
    
    private String getProductName(String name)
    {
        String productName = BXLConfigLoader.PRODUCT_NAME_SPP_R200II;

        if((name.indexOf("SPP-R200II") >= 0))
        {
            if(name.length() > 10)
            {
                if(name.substring(10, 11).equals("I"))
                {
                    productName = BXLConfigLoader.PRODUCT_NAME_SPP_R200III;
                }
            }
        }
        else if((name.indexOf("SPP-R210") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R210;
        }
        else if((name.indexOf("SPP-R215") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R215;
        }
        else if((name.indexOf("SPP-R220") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R220;
        }
        else if((name.indexOf("SPP-R300") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R300;
        }
        else if((name.indexOf("SPP-R310") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R310;
        }
        else if((name.indexOf("SPP-R318") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R318;
        }
        else if((name.indexOf("SPP-R400") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R400;
        }
        else if((name.indexOf("SPP-R410") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R410;
        }
        else if((name.indexOf("SPP-R418") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SPP_R418;
        }
        else if((name.indexOf("SRP-350III") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_350III;
        }
        else if((name.indexOf("SRP-352III") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_352III;
        }
        else if((name.indexOf("SRP-350plusIII") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_350PLUSIII;
        }
        else if((name.indexOf("SRP-352plusIII") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_352PLUSIII;
        }
        else if((name.indexOf("SRP-380") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_380;
        }
        else if((name.indexOf("SRP-382") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_382;
        }
        else if((name.indexOf("SRP-383") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_383;
        }
        else if((name.indexOf("SRP-340II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_340II;
        }
        else if((name.indexOf("SRP-342II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_342II;
        }
        else if((name.indexOf("SRP-Q300") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_Q300;
        }
        else if((name.indexOf("SRP-Q302") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_Q302;
        }
		else if((name.indexOf("SRP-QE300") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SRP_QE300;
		}
		else if((name.indexOf("SRP-QE302") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SRP_QE302;
		}
		else if((name.indexOf("SRP-E300") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SRP_E300;
		}
		else if((name.indexOf("SRP-E302") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SRP_E302;
		}
        else if((name.indexOf("SRP-330II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_330II;
        }
        else if((name.indexOf("SRP-332II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_332II;
        }
        else if((name.indexOf("SRP-S300") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_S300;
        }
        else if((name.indexOf("SRP-F310II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_F310II;
        }
        else if((name.indexOf("SRP-F312II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_F312II;
        }
        else if((name.indexOf("SRP-F313II") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_F313II;
        }
        else if((name.indexOf("SRP-275III") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SRP_275III;
        }
        else if((name.indexOf("MSR") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_MSR;
        }
        else if((name.indexOf("SmartCardRW") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_SMART_CARD_RW;
        }
        else if((name.indexOf("CashDrawer") >= 0))
        {
            productName = BXLConfigLoader.PRODUCT_NAME_CASH_DRAWER;
        }

        return productName;
    }

    @Override
    public void outputCompleteOccurred(OutputCompleteEvent outputCompleteEvent) {
        if(outputCompleteCallback != null)
        {
            try {
                JSONObject parameter = new JSONObject();
                parameter.put("OutputID", outputCompleteEvent.getOutputID());
                PluginResult result = new PluginResult(PluginResult.Status.OK, parameter);
                result.setKeepCallback(true);
                outputCompleteCallback.sendPluginResult(result);
            } catch (JSONException e) {
                Log.e(TAG, e.toString());
            }
        }
    }

    private byte[] StringToHex(String strScr) {
        int len = strScr.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(strScr.charAt(i), 16) << 4)
                    + Character.digit(strScr.charAt(i + 1), 16));
        }
        return data;
    }
}
