import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/services/user_equipment_resolver.dart';

void main() {
  group('UserEquipmentResolver.toMasterCodes', () {
    test('mappa i codici utente M2 nei codici master', () {
      final result = UserEquipmentResolver.toMasterCodes([
        'resistance_bands',
        'dumbbells_10kg',
        'chair',
        'wall',
        'mat',
        'step',
      ]);
      expect(result, {'BAND', 'DUMBBELL', 'CHAIR', 'WALL', 'MAT', 'STEP'});
    });

    test('resistance_bands -> BAND', () {
      expect(UserEquipmentResolver.toMasterCodes(['resistance_bands']), {
        'BAND',
      });
    });

    test('dumbbells_10kg -> DUMBBELL', () {
      expect(UserEquipmentResolver.toMasterCodes(['dumbbells_10kg']), {
        'DUMBBELL',
      });
    });

    test('un codice sconosciuto non genera attrezzature master inventate', () {
      final result = UserEquipmentResolver.toMasterCodes([
        'chair',
        'codice_inesistente',
      ]);
      expect(result, {'CHAIR'});
    });

    test('lista vuota -> insieme vuoto', () {
      expect(UserEquipmentResolver.toMasterCodes(const []), isEmpty);
    });
  });
}
