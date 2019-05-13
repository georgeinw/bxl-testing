package com.bxl.service.phonegap;

import java.util.Set;

import android.app.AlertDialog;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

import jpos.JposException;
import jpos.POSPrinter;
import jpos.config.JposEntry;
import com.bxl.config.editor.BXLConfigLoader;

public class DialogManager
{

	static void showBluetoothDialog(final Context context, final Set<BluetoothDevice> pairedDevices)
	{
		final String[] strDevice = new String[pairedDevices.size()];
		int k = 0;
		for(BluetoothDevice device:pairedDevices)
		{
			strDevice[k] = device.getName() + BXLService.DEVICE_ADDRESS_START + device.getAddress() + BXLService.DEVICE_ADDRESS_END;
			k++;
		}

		new AlertDialog.Builder(context).setTitle("Paired Bluetooth printers").setItems(strDevice, new DialogInterface.OnClickListener()
		{
			public void onClick(DialogInterface dialog, int which)
			{
				String strSelectList = strDevice[which];
				String temp;
				int indexSpace = 0;

				String logicalName = strSelectList.substring(0, strSelectList.indexOf(BXLService.DEVICE_ADDRESS_START));
				String address = strSelectList.substring(strSelectList.indexOf(BXLService.DEVICE_ADDRESS_START) + BXLService.DEVICE_ADDRESS_START.length(), strSelectList.indexOf(BXLService.DEVICE_ADDRESS_END));
/*
				try
				{
					for(Object entry:BXLService.bxlConfigLoader.getEntries())
					{
						JposEntry jposEntry = (JposEntry) entry;
						BXLService.bxlConfigLoader.removeEntry(jposEntry.getLogicalName());
					}
				}
				catch(Exception e)
				{
					e.printStackTrace();
				}

				try
				{
					BXLService.bxlConfigLoader.addEntry(logicalName, BXLConfigLoader.DEVICE_CATEGORY_POS_PRINTER, setProductName(logicalName), BXLConfigLoader.DEVICE_BUS_BLUETOOTH, address);

					BXLService.bxlConfigLoader.saveFile();
				}
				catch(Exception e)
				{
					e.printStackTrace();
				}

				try
				{
					BXLService.posPrinter.open(logicalName);
					BXLService.posPrinter.claim(0);
					BXLService.posPrinter.setDeviceEnabled(true);
				}
				catch(JposException e)
				{
					e.printStackTrace();

					try
					{
						BXLService.posPrinter.close();
					}
					catch(JposException e1)
					{
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
				}*/
			}

		}).show();
	}

	private static String setProductName(String name)
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
		else if((name.indexOf("SPP-R310") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SPP_R310;
		}
		else if((name.indexOf("SPP-R300") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SPP_R300;
		}
		else if((name.indexOf("SPP-R400") >= 0))
		{
			productName = BXLConfigLoader.PRODUCT_NAME_SPP_R400;
		}

		return productName;
	}
}
