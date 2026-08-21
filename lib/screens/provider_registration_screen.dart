// _submitPartnerToFirestore method ke andar coordinates add karein:
Position? currentPosition = await LocationService.getCurrentPosition();

await FirebaseFirestore.instance.collection('providers').doc(user.uid).set({
  'userId': user.uid,
  'name': _nameController.text.trim(),
  'phone': _phoneController.text.trim(),
  'category': _selectedCategory,
  'experience': _experienceController.text.trim(),
  'baseRate': int.tryParse(_rateController.text.trim()) ?? 299,
  'location': _locationController.text.trim(),
  'lat': currentPosition?.latitude ?? 26.1445, // Default Assam Lat
  'lng': currentPosition?.longitude ?? 91.7362, // Default Assam Lng
  'isVerified': true,
  'rating': 5.0,
  'totalJobs': 0,
  'totalEarnings': 0,
  'isOnline': true,
  'registeredAt': FieldValue.serverTimestamp(),
});
