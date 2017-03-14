// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"

HINSTANCE mHinstDLL = 0;
extern "C" UINT_PTR mProcs[277] = { 0 };

// ShowWindow hooking
typedef bool(__stdcall* ShowWindow_t)(HWND hWnd, int nCmdShow);
static ShowWindow_t pShowWindow = NULL;
bool ShowWindow_Hook(HWND hWnd, int nCmdShow) {
	if (hWnd == GetConsoleWindow() && nCmdShow == 0) {
		// Prevent hiding the console window
		return true;
	}

	// Otherwise just run the original
	return pShowWindow(hWnd, nCmdShow);
}

// GetVolumeInformationA hooking
typedef bool(__stdcall* GetVolume_t)(LPCTSTR lpRootPathName, LPTSTR lpVolumeNameBuffer, DWORD nVolumeNameSize, LPDWORD lpVolumeSerialNumber, LPDWORD lpMaximumComponentLength, LPDWORD lpFileSystemFlags, LPTSTR lpFileSystemNameBuffer, DWORD nFileSystemNameSize);
static GetVolume_t pGetVolume = NULL;
bool GetVolume_hook(LPCTSTR lpRootPathName, LPTSTR lpVolumeNameBuffer, DWORD nVolumeNameSize, LPDWORD lpVolumeSerialNumber, LPDWORD lpMaximumComponentLength, LPDWORD lpFileSystemFlags, LPTSTR lpFileSystemNameBuffer, DWORD nFileSystemNameSize) {

	srand((unsigned)time(0));
	DWORD random = (rand()<<16)+rand();

	bool result = pGetVolume(lpRootPathName, lpVolumeNameBuffer, nVolumeNameSize, lpVolumeSerialNumber, lpMaximumComponentLength, lpFileSystemFlags, lpFileSystemNameBuffer, nFileSystemNameSize);
	// Randomize VSN
	*lpVolumeSerialNumber = random;
	return result;
}

// RegOpenKeyExW hooking
typedef long(__stdcall* RegOpen_t)(HKEY hKey, LPCTSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult);
static RegOpen_t pRegOpen = NULL;
long RegOpen_hook(HKEY hKey, LPCTSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult) {
//	wprintf(L"RegOpenKey called with %s\n", (wchar_t *)lpSubKey);
	long result = pRegOpen(hKey, lpSubKey, ulOptions, samDesired, phkResult);
	return result;
}

DWORD WINAPI MyThread(LPVOID lpParam)
{
	Hooking::Start((HMODULE)lpParam);
	return 0;
}

// load the dll proxy and place the bypasses for all the exports
LPCSTR mExportNames[] = {"AddIPAddress", "AllocateAndGetInterfaceInfoFromStack", "AllocateAndGetIpAddrTableFromStack", "CancelIPChangeNotify", "CancelMibChangeNotify2", "CloseCompartment", "CloseGetIPPhysicalInterfaceForDestination", "ConvertCompartmentGuidToId", "ConvertCompartmentIdToGuid", "ConvertGuidToStringA", "ConvertGuidToStringW", "ConvertInterfaceAliasToLuid", "ConvertInterfaceGuidToLuid", "ConvertInterfaceIndexToLuid", "ConvertInterfaceLuidToAlias", "ConvertInterfaceLuidToGuid", "ConvertInterfaceLuidToIndex", "ConvertInterfaceLuidToNameA", "ConvertInterfaceLuidToNameW", "ConvertInterfaceNameToLuidA", "ConvertInterfaceNameToLuidW", "ConvertInterfacePhysicalAddressToLuid", "ConvertIpv4MaskToLength", "ConvertLengthToIpv4Mask", "ConvertRemoteInterfaceAliasToLuid", "ConvertRemoteInterfaceGuidToLuid", "ConvertRemoteInterfaceIndexToLuid", "ConvertRemoteInterfaceLuidToAlias", "ConvertRemoteInterfaceLuidToGuid", "ConvertRemoteInterfaceLuidToIndex", "ConvertStringToGuidA", "ConvertStringToGuidW", "ConvertStringToInterfacePhysicalAddress", "CreateAnycastIpAddressEntry", "CreateCompartment", "CreateIpForwardEntry", "CreateIpForwardEntry2", "CreateIpNetEntry", "CreateIpNetEntry2", "CreatePersistentTcpPortReservation", "CreatePersistentUdpPortReservation", "CreateProxyArpEntry", "CreateSortedAddressPairs", "CreateUnicastIpAddressEntry", "DeleteAnycastIpAddressEntry", "DeleteCompartment", "DeleteIPAddress", "DeleteIpForwardEntry", "DeleteIpForwardEntry2", "DeleteIpNetEntry", "DeleteIpNetEntry2", "DeletePersistentTcpPortReservation", "DeletePersistentUdpPortReservation", "DeleteProxyArpEntry", "DeleteUnicastIpAddressEntry", "DisableMediaSense", "EnableRouter", "FlushIpNetTable", "FlushIpNetTable2", "FlushIpPathTable", "FreeMibTable", "GetAdapterIndex", "GetAdapterOrderMap", "GetAdaptersAddresses", "GetAdaptersInfo", "GetAnycastIpAddressEntry", "GetAnycastIpAddressTable", "GetBestInterface", "GetBestInterfaceEx", "GetBestRoute", "GetBestRoute2", "GetCurrentThreadCompartmentId", "GetCurrentThreadCompartmentScope", "GetExtendedTcpTable", "GetExtendedUdpTable", "GetFriendlyIfIndex", "GetIcmpStatistics", "GetIcmpStatisticsEx", "GetIfEntry", "GetIfEntry2", "GetIfStackTable", "GetIfTable", "GetIfTable2", "GetIfTable2Ex", "GetInterfaceInfo", "GetInvertedIfStackTable", "GetIpAddrTable", "GetIpErrorString", "GetIpForwardEntry2", "GetIpForwardTable", "GetIpForwardTable2", "GetIpInterfaceEntry", "GetIpInterfaceTable", "GetIpNetEntry2", "GetIpNetTable", "GetIpNetTable2", "GetIpNetworkConnectionBandwidthEstimates", "GetIpPathEntry", "GetIpPathTable", "GetIpStatistics", "GetIpStatisticsEx", "GetJobCompartmentId", "GetMulticastIpAddressEntry", "GetMulticastIpAddressTable", "GetNetworkInformation", "GetNetworkParams", "GetNumberOfInterfaces", "GetOwnerModuleFromPidAndInfo", "GetOwnerModuleFromTcp6Entry", "GetOwnerModuleFromTcpEntry", "GetOwnerModuleFromUdp6Entry", "GetOwnerModuleFromUdpEntry", "GetPerAdapterInfo", "GetPerTcp6ConnectionEStats", "GetPerTcp6ConnectionStats", "GetPerTcpConnectionEStats", "GetPerTcpConnectionStats", "GetRTTAndHopCount", "GetSessionCompartmentId", "GetTcp6Table", "GetTcp6Table2", "GetTcpStatistics", "GetTcpStatisticsEx", "GetTcpTable", "GetTcpTable2", "GetTeredoPort", "GetUdp6Table", "GetUdpStatistics", "GetUdpStatisticsEx", "GetUdpTable", "GetUniDirectionalAdapterInfo", "GetUnicastIpAddressEntry", "GetUnicastIpAddressTable", "GetWPAOACSupportLevel", "Icmp6CreateFile", "Icmp6ParseReplies", "Icmp6SendEcho2", "IcmpCloseHandle", "IcmpCreateFile", "IcmpParseReplies", "IcmpSendEcho", "IcmpSendEcho2", "IcmpSendEcho2Ex", "InitializeCompartmentEntry", "InitializeIpForwardEntry", "InitializeIpInterfaceEntry", "InitializeUnicastIpAddressEntry", "InternalCleanupPersistentStore", "InternalCreateAnycastIpAddressEntry", "InternalCreateIpForwardEntry", "InternalCreateIpForwardEntry2", "InternalCreateIpNetEntry", "InternalCreateIpNetEntry2", "InternalCreateUnicastIpAddressEntry", "InternalDeleteAnycastIpAddressEntry", "InternalDeleteIpForwardEntry", "InternalDeleteIpForwardEntry2", "InternalDeleteIpNetEntry", "InternalDeleteIpNetEntry2", "InternalDeleteUnicastIpAddressEntry", "InternalFindInterfaceByAddress", "InternalGetAnycastIpAddressEntry", "InternalGetAnycastIpAddressTable", "InternalGetBoundTcp6EndpointTable", "InternalGetBoundTcpEndpointTable", "InternalGetForwardIpTable2", "InternalGetIPPhysicalInterfaceForDestination", "InternalGetIfEntry2", "InternalGetIfTable", "InternalGetIfTable2", "InternalGetIpAddrTable", "InternalGetIpForwardEntry2", "InternalGetIpForwardTable", "InternalGetIpInterfaceEntry", "InternalGetIpInterfaceTable", "InternalGetIpNetEntry2", "InternalGetIpNetTable", "InternalGetIpNetTable2", "InternalGetMulticastIpAddressEntry", "InternalGetMulticastIpAddressTable", "InternalGetRtcSlotInformation", "InternalGetTcp6Table2", "InternalGetTcp6TableWithOwnerModule", "InternalGetTcp6TableWithOwnerPid", "InternalGetTcpTable", "InternalGetTcpTable2", "InternalGetTcpTableEx", "InternalGetTcpTableWithOwnerModule", "InternalGetTcpTableWithOwnerPid", "InternalGetTunnelPhysicalAdapter", "InternalGetUdp6TableWithOwnerModule", "InternalGetUdp6TableWithOwnerPid", "InternalGetUdpTable", "InternalGetUdpTableEx", "InternalGetUdpTableWithOwnerModule", "InternalGetUdpTableWithOwnerPid", "InternalGetUnicastIpAddressEntry", "InternalGetUnicastIpAddressTable", "InternalIcmpCreateFileEx", "InternalSetIfEntry", "InternalSetIpForwardEntry", "InternalSetIpForwardEntry2", "InternalSetIpInterfaceEntry", "InternalSetIpNetEntry", "InternalSetIpNetEntry2", "InternalSetIpStats", "InternalSetTcpEntry", "InternalSetTeredoPort", "InternalSetUnicastIpAddressEntry", "IpReleaseAddress", "IpRenewAddress", "LookupPersistentTcpPortReservation", "LookupPersistentUdpPortReservation", "NTPTimeToNTFileTime", "NTTimeToNTPTime", "NhGetGuidFromInterfaceName", "NhGetInterfaceDescriptionFromGuid", "NhGetInterfaceNameFromDeviceGuid", "NhGetInterfaceNameFromGuid", "NhpAllocateAndGetInterfaceInfoFromStack", "NotifyAddrChange", "NotifyCompartmentChange", "NotifyIpInterfaceChange", "NotifyRouteChange", "NotifyRouteChange2", "NotifyStableUnicastIpAddressTable", "NotifyTeredoPortChange", "NotifyUnicastIpAddressChange", "OpenCompartment", "ParseNetworkString", "PfAddFiltersToInterface", "PfAddGlobalFilterToInterface", "PfBindInterfaceToIPAddress", "PfBindInterfaceToIndex", "PfCreateInterface", "PfDeleteInterface", "PfDeleteLog", "PfGetInterfaceStatistics", "PfMakeLog", "PfRebindFilters", "PfRemoveFilterHandles", "PfRemoveFiltersFromInterface", "PfRemoveGlobalFilterFromInterface", "PfSetLogBuffer", "PfTestPacket", "PfUnBindInterface", "ResolveIpNetEntry2", "ResolveNeighbor", "RestoreMediaSense", "SendARP", "SetAdapterIpAddress", "SetCurrentThreadCompartmentId", "SetCurrentThreadCompartmentScope", "SetIfEntry", "SetIpForwardEntry", "SetIpForwardEntry2", "SetIpInterfaceEntry", "SetIpNetEntry", "SetIpNetEntry2", "SetIpStatistics", "SetIpStatisticsEx", "SetIpTTL", "SetJobCompartmentId", "SetNetworkInformation", "SetPerTcp6ConnectionEStats", "SetPerTcp6ConnectionStats", "SetPerTcpConnectionEStats", "SetPerTcpConnectionStats", "SetSessionCompartmentId", "SetTcpEntry", "SetUnicastIpAddressEntry", "UnenableRouter", "do_echo_rep", "do_echo_req", "if_indextoname", "if_nametoindex", "register_icmp"};

BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
{

	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:

		// Attach a debug console
		ConsoleAttach();
		SetTextFGColor(3);
		printf(DASH);
		printf(MODULE_TITLE);
		printf(DASH);
		SetTextFGColor(7);
		printf(BUILT_ON);

		printf(INIT_MINHOOK);
		if (MH_Initialize() != MH_OK) {
			printf(FAILED_INIT_MINHOOK);
			return(FALSE);
		}
		printf(OK);

		// Prevents GTA from closing the console window
		Hooking::HookLibraryFunction("user32.dll", "ShowWindow", &ShowWindow_Hook, (void**)&pShowWindow);
		Hooking::HookLibraryFunction("kernel32.dll", "GetVolumeInformationA", &GetVolume_hook, (void**)&pGetVolume);
		Hooking::HookLibraryFunction("advapi32.dll", "RegOpenKeyExW", &RegOpen_hook, (void**)&pRegOpen);

		printf(REMAP_EXPORTS);
		// Find original dll
		char syspath[MAX_PATH];
		GetSystemDirectory(syspath, MAX_PATH);
		sprintf_s(syspath, MAX_PATH, "%s\\" DLLNAME, syspath);

		// Load it
		mHinstDLL = LoadLibrary(syspath);
		if (!mHinstDLL) {
			MessageBox(NULL, NO_ORIGINAL_DLL, FATAL_ERROR, NULL);
			return (FALSE);
		}

		// Map the exports
		for (int i = 0; i < 277; i++)
			mProcs[i] = (UINT_PTR)GetProcAddress(mHinstDLL, mExportNames[i]);

		printf(OK);

		// Do whatever you want from this point on
		// Arbitrary code starts here

		printf(CREATE_THREAD);
		CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)MyThread, hModule, NULL, NULL);
		printf(OK);
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		Hooking::Cleanup();
		break;
	}
	return TRUE;
}

// wrappers for the original dll go here
extern "C" void AddIPAddress_wrapper();
extern "C" void AllocateAndGetInterfaceInfoFromStack_wrapper();
extern "C" void AllocateAndGetIpAddrTableFromStack_wrapper();
extern "C" void CancelIPChangeNotify_wrapper();
extern "C" void CancelMibChangeNotify2_wrapper();
extern "C" void CloseCompartment_wrapper();
extern "C" void CloseGetIPPhysicalInterfaceForDestination_wrapper();
extern "C" void ConvertCompartmentGuidToId_wrapper();
extern "C" void ConvertCompartmentIdToGuid_wrapper();
extern "C" void ConvertGuidToStringA_wrapper();
extern "C" void ConvertGuidToStringW_wrapper();
extern "C" void ConvertInterfaceAliasToLuid_wrapper();
extern "C" void ConvertInterfaceGuidToLuid_wrapper();
extern "C" void ConvertInterfaceIndexToLuid_wrapper();
extern "C" void ConvertInterfaceLuidToAlias_wrapper();
extern "C" void ConvertInterfaceLuidToGuid_wrapper();
extern "C" void ConvertInterfaceLuidToIndex_wrapper();
extern "C" void ConvertInterfaceLuidToNameA_wrapper();
extern "C" void ConvertInterfaceLuidToNameW_wrapper();
extern "C" void ConvertInterfaceNameToLuidA_wrapper();
extern "C" void ConvertInterfaceNameToLuidW_wrapper();
extern "C" void ConvertInterfacePhysicalAddressToLuid_wrapper();
extern "C" void ConvertIpv4MaskToLength_wrapper();
extern "C" void ConvertLengthToIpv4Mask_wrapper();
extern "C" void ConvertRemoteInterfaceAliasToLuid_wrapper();
extern "C" void ConvertRemoteInterfaceGuidToLuid_wrapper();
extern "C" void ConvertRemoteInterfaceIndexToLuid_wrapper();
extern "C" void ConvertRemoteInterfaceLuidToAlias_wrapper();
extern "C" void ConvertRemoteInterfaceLuidToGuid_wrapper();
extern "C" void ConvertRemoteInterfaceLuidToIndex_wrapper();
extern "C" void ConvertStringToGuidA_wrapper();
extern "C" void ConvertStringToGuidW_wrapper();
extern "C" void ConvertStringToInterfacePhysicalAddress_wrapper();
extern "C" void CreateAnycastIpAddressEntry_wrapper();
extern "C" void CreateCompartment_wrapper();
extern "C" void CreateIpForwardEntry_wrapper();
extern "C" void CreateIpForwardEntry2_wrapper();
extern "C" void CreateIpNetEntry_wrapper();
extern "C" void CreateIpNetEntry2_wrapper();
extern "C" void CreatePersistentTcpPortReservation_wrapper();
extern "C" void CreatePersistentUdpPortReservation_wrapper();
extern "C" void CreateProxyArpEntry_wrapper();
extern "C" void CreateSortedAddressPairs_wrapper();
extern "C" void CreateUnicastIpAddressEntry_wrapper();
extern "C" void DeleteAnycastIpAddressEntry_wrapper();
extern "C" void DeleteCompartment_wrapper();
extern "C" void DeleteIPAddress_wrapper();
extern "C" void DeleteIpForwardEntry_wrapper();
extern "C" void DeleteIpForwardEntry2_wrapper();
extern "C" void DeleteIpNetEntry_wrapper();
extern "C" void DeleteIpNetEntry2_wrapper();
extern "C" void DeletePersistentTcpPortReservation_wrapper();
extern "C" void DeletePersistentUdpPortReservation_wrapper();
extern "C" void DeleteProxyArpEntry_wrapper();
extern "C" void DeleteUnicastIpAddressEntry_wrapper();
extern "C" void DisableMediaSense_wrapper();
extern "C" void EnableRouter_wrapper();
extern "C" void FlushIpNetTable_wrapper();
extern "C" void FlushIpNetTable2_wrapper();
extern "C" void FlushIpPathTable_wrapper();
extern "C" void FreeMibTable_wrapper();
extern "C" void GetAdapterIndex_wrapper();
extern "C" void GetAdapterOrderMap_wrapper();
extern "C" void GetAdaptersAddresses_wrapper();
extern "C" void GetAdaptersInfo_wrapper();
extern "C" void GetAnycastIpAddressEntry_wrapper();
extern "C" void GetAnycastIpAddressTable_wrapper();
extern "C" void GetBestInterface_wrapper();
extern "C" void GetBestInterfaceEx_wrapper();
extern "C" void GetBestRoute_wrapper();
extern "C" void GetBestRoute2_wrapper();
extern "C" void GetCurrentThreadCompartmentId_wrapper();
extern "C" void GetCurrentThreadCompartmentScope_wrapper();
extern "C" void GetExtendedTcpTable_wrapper();
extern "C" void GetExtendedUdpTable_wrapper();
extern "C" void GetFriendlyIfIndex_wrapper();
extern "C" void GetIcmpStatistics_wrapper();
extern "C" void GetIcmpStatisticsEx_wrapper();
extern "C" void GetIfEntry_wrapper();
extern "C" void GetIfEntry2_wrapper();
extern "C" void GetIfStackTable_wrapper();
extern "C" void GetIfTable_wrapper();
extern "C" void GetIfTable2_wrapper();
extern "C" void GetIfTable2Ex_wrapper();
extern "C" void GetInterfaceInfo_wrapper();
extern "C" void GetInvertedIfStackTable_wrapper();
extern "C" void GetIpAddrTable_wrapper();
extern "C" void GetIpErrorString_wrapper();
extern "C" void GetIpForwardEntry2_wrapper();
extern "C" void GetIpForwardTable_wrapper();
extern "C" void GetIpForwardTable2_wrapper();
extern "C" void GetIpInterfaceEntry_wrapper();
extern "C" void GetIpInterfaceTable_wrapper();
extern "C" void GetIpNetEntry2_wrapper();
extern "C" void GetIpNetTable_wrapper();
extern "C" void GetIpNetTable2_wrapper();
extern "C" void GetIpNetworkConnectionBandwidthEstimates_wrapper();
extern "C" void GetIpPathEntry_wrapper();
extern "C" void GetIpPathTable_wrapper();
extern "C" void GetIpStatistics_wrapper();
extern "C" void GetIpStatisticsEx_wrapper();
extern "C" void GetJobCompartmentId_wrapper();
extern "C" void GetMulticastIpAddressEntry_wrapper();
extern "C" void GetMulticastIpAddressTable_wrapper();
extern "C" void GetNetworkInformation_wrapper();
extern "C" void GetNetworkParams_wrapper();
extern "C" void GetNumberOfInterfaces_wrapper();
extern "C" void GetOwnerModuleFromPidAndInfo_wrapper();
extern "C" void GetOwnerModuleFromTcp6Entry_wrapper();
extern "C" void GetOwnerModuleFromTcpEntry_wrapper();
extern "C" void GetOwnerModuleFromUdp6Entry_wrapper();
extern "C" void GetOwnerModuleFromUdpEntry_wrapper();
extern "C" void GetPerAdapterInfo_wrapper();
extern "C" void GetPerTcp6ConnectionEStats_wrapper();
extern "C" void GetPerTcp6ConnectionStats_wrapper();
extern "C" void GetPerTcpConnectionEStats_wrapper();
extern "C" void GetPerTcpConnectionStats_wrapper();
extern "C" void GetRTTAndHopCount_wrapper();
extern "C" void GetSessionCompartmentId_wrapper();
extern "C" void GetTcp6Table_wrapper();
extern "C" void GetTcp6Table2_wrapper();
extern "C" void GetTcpStatistics_wrapper();
extern "C" void GetTcpStatisticsEx_wrapper();
extern "C" void GetTcpTable_wrapper();
extern "C" void GetTcpTable2_wrapper();
extern "C" void GetTeredoPort_wrapper();
extern "C" void GetUdp6Table_wrapper();
extern "C" void GetUdpStatistics_wrapper();
extern "C" void GetUdpStatisticsEx_wrapper();
extern "C" void GetUdpTable_wrapper();
extern "C" void GetUniDirectionalAdapterInfo_wrapper();
extern "C" void GetUnicastIpAddressEntry_wrapper();
extern "C" void GetUnicastIpAddressTable_wrapper();
extern "C" void GetWPAOACSupportLevel_wrapper();
extern "C" void Icmp6CreateFile_wrapper();
extern "C" void Icmp6ParseReplies_wrapper();
extern "C" void Icmp6SendEcho2_wrapper();
extern "C" void IcmpCloseHandle_wrapper();
extern "C" void IcmpCreateFile_wrapper();
extern "C" void IcmpParseReplies_wrapper();
extern "C" void IcmpSendEcho_wrapper();
extern "C" void IcmpSendEcho2_wrapper();
extern "C" void IcmpSendEcho2Ex_wrapper();
extern "C" void InitializeCompartmentEntry_wrapper();
extern "C" void InitializeIpForwardEntry_wrapper();
extern "C" void InitializeIpInterfaceEntry_wrapper();
extern "C" void InitializeUnicastIpAddressEntry_wrapper();
extern "C" void InternalCleanupPersistentStore_wrapper();
extern "C" void InternalCreateAnycastIpAddressEntry_wrapper();
extern "C" void InternalCreateIpForwardEntry_wrapper();
extern "C" void InternalCreateIpForwardEntry2_wrapper();
extern "C" void InternalCreateIpNetEntry_wrapper();
extern "C" void InternalCreateIpNetEntry2_wrapper();
extern "C" void InternalCreateUnicastIpAddressEntry_wrapper();
extern "C" void InternalDeleteAnycastIpAddressEntry_wrapper();
extern "C" void InternalDeleteIpForwardEntry_wrapper();
extern "C" void InternalDeleteIpForwardEntry2_wrapper();
extern "C" void InternalDeleteIpNetEntry_wrapper();
extern "C" void InternalDeleteIpNetEntry2_wrapper();
extern "C" void InternalDeleteUnicastIpAddressEntry_wrapper();
extern "C" void InternalFindInterfaceByAddress_wrapper();
extern "C" void InternalGetAnycastIpAddressEntry_wrapper();
extern "C" void InternalGetAnycastIpAddressTable_wrapper();
extern "C" void InternalGetBoundTcp6EndpointTable_wrapper();
extern "C" void InternalGetBoundTcpEndpointTable_wrapper();
extern "C" void InternalGetForwardIpTable2_wrapper();
extern "C" void InternalGetIPPhysicalInterfaceForDestination_wrapper();
extern "C" void InternalGetIfEntry2_wrapper();
extern "C" void InternalGetIfTable_wrapper();
extern "C" void InternalGetIfTable2_wrapper();
extern "C" void InternalGetIpAddrTable_wrapper();
extern "C" void InternalGetIpForwardEntry2_wrapper();
extern "C" void InternalGetIpForwardTable_wrapper();
extern "C" void InternalGetIpInterfaceEntry_wrapper();
extern "C" void InternalGetIpInterfaceTable_wrapper();
extern "C" void InternalGetIpNetEntry2_wrapper();
extern "C" void InternalGetIpNetTable_wrapper();
extern "C" void InternalGetIpNetTable2_wrapper();
extern "C" void InternalGetMulticastIpAddressEntry_wrapper();
extern "C" void InternalGetMulticastIpAddressTable_wrapper();
extern "C" void InternalGetRtcSlotInformation_wrapper();
extern "C" void InternalGetTcp6Table2_wrapper();
extern "C" void InternalGetTcp6TableWithOwnerModule_wrapper();
extern "C" void InternalGetTcp6TableWithOwnerPid_wrapper();
extern "C" void InternalGetTcpTable_wrapper();
extern "C" void InternalGetTcpTable2_wrapper();
extern "C" void InternalGetTcpTableEx_wrapper();
extern "C" void InternalGetTcpTableWithOwnerModule_wrapper();
extern "C" void InternalGetTcpTableWithOwnerPid_wrapper();
extern "C" void InternalGetTunnelPhysicalAdapter_wrapper();
extern "C" void InternalGetUdp6TableWithOwnerModule_wrapper();
extern "C" void InternalGetUdp6TableWithOwnerPid_wrapper();
extern "C" void InternalGetUdpTable_wrapper();
extern "C" void InternalGetUdpTableEx_wrapper();
extern "C" void InternalGetUdpTableWithOwnerModule_wrapper();
extern "C" void InternalGetUdpTableWithOwnerPid_wrapper();
extern "C" void InternalGetUnicastIpAddressEntry_wrapper();
extern "C" void InternalGetUnicastIpAddressTable_wrapper();
extern "C" void InternalIcmpCreateFileEx_wrapper();
extern "C" void InternalSetIfEntry_wrapper();
extern "C" void InternalSetIpForwardEntry_wrapper();
extern "C" void InternalSetIpForwardEntry2_wrapper();
extern "C" void InternalSetIpInterfaceEntry_wrapper();
extern "C" void InternalSetIpNetEntry_wrapper();
extern "C" void InternalSetIpNetEntry2_wrapper();
extern "C" void InternalSetIpStats_wrapper();
extern "C" void InternalSetTcpEntry_wrapper();
extern "C" void InternalSetTeredoPort_wrapper();
extern "C" void InternalSetUnicastIpAddressEntry_wrapper();
extern "C" void IpReleaseAddress_wrapper();
extern "C" void IpRenewAddress_wrapper();
extern "C" void LookupPersistentTcpPortReservation_wrapper();
extern "C" void LookupPersistentUdpPortReservation_wrapper();
extern "C" void NTPTimeToNTFileTime_wrapper();
extern "C" void NTTimeToNTPTime_wrapper();
extern "C" void NhGetGuidFromInterfaceName_wrapper();
extern "C" void NhGetInterfaceDescriptionFromGuid_wrapper();
extern "C" void NhGetInterfaceNameFromDeviceGuid_wrapper();
extern "C" void NhGetInterfaceNameFromGuid_wrapper();
extern "C" void NhpAllocateAndGetInterfaceInfoFromStack_wrapper();
extern "C" void NotifyAddrChange_wrapper();
extern "C" void NotifyCompartmentChange_wrapper();
extern "C" void NotifyIpInterfaceChange_wrapper();
extern "C" void NotifyRouteChange_wrapper();
extern "C" void NotifyRouteChange2_wrapper();
extern "C" void NotifyStableUnicastIpAddressTable_wrapper();
extern "C" void NotifyTeredoPortChange_wrapper();
extern "C" void NotifyUnicastIpAddressChange_wrapper();
extern "C" void OpenCompartment_wrapper();
extern "C" void ParseNetworkString_wrapper();
extern "C" void PfAddFiltersToInterface_wrapper();
extern "C" void PfAddGlobalFilterToInterface_wrapper();
extern "C" void PfBindInterfaceToIPAddress_wrapper();
extern "C" void PfBindInterfaceToIndex_wrapper();
extern "C" void PfCreateInterface_wrapper();
extern "C" void PfDeleteInterface_wrapper();
extern "C" void PfDeleteLog_wrapper();
extern "C" void PfGetInterfaceStatistics_wrapper();
extern "C" void PfMakeLog_wrapper();
extern "C" void PfRebindFilters_wrapper();
extern "C" void PfRemoveFilterHandles_wrapper();
extern "C" void PfRemoveFiltersFromInterface_wrapper();
extern "C" void PfRemoveGlobalFilterFromInterface_wrapper();
extern "C" void PfSetLogBuffer_wrapper();
extern "C" void PfTestPacket_wrapper();
extern "C" void PfUnBindInterface_wrapper();
extern "C" void ResolveIpNetEntry2_wrapper();
extern "C" void ResolveNeighbor_wrapper();
extern "C" void RestoreMediaSense_wrapper();
extern "C" void SendARP_wrapper();
extern "C" void SetAdapterIpAddress_wrapper();
extern "C" void SetCurrentThreadCompartmentId_wrapper();
extern "C" void SetCurrentThreadCompartmentScope_wrapper();
extern "C" void SetIfEntry_wrapper();
extern "C" void SetIpForwardEntry_wrapper();
extern "C" void SetIpForwardEntry2_wrapper();
extern "C" void SetIpInterfaceEntry_wrapper();
extern "C" void SetIpNetEntry_wrapper();
extern "C" void SetIpNetEntry2_wrapper();
extern "C" void SetIpStatistics_wrapper();
extern "C" void SetIpStatisticsEx_wrapper();
extern "C" void SetIpTTL_wrapper();
extern "C" void SetJobCompartmentId_wrapper();
extern "C" void SetNetworkInformation_wrapper();
extern "C" void SetPerTcp6ConnectionEStats_wrapper();
extern "C" void SetPerTcp6ConnectionStats_wrapper();
extern "C" void SetPerTcpConnectionEStats_wrapper();
extern "C" void SetPerTcpConnectionStats_wrapper();
extern "C" void SetSessionCompartmentId_wrapper();
extern "C" void SetTcpEntry_wrapper();
extern "C" void SetUnicastIpAddressEntry_wrapper();
extern "C" void UnenableRouter_wrapper();
extern "C" void do_echo_rep_wrapper();
extern "C" void do_echo_req_wrapper();
extern "C" void if_indextoname_wrapper();
extern "C" void if_nametoindex_wrapper();
extern "C" void register_icmp_wrapper();
