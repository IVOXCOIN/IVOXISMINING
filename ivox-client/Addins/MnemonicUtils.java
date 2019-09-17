//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.web3j.crypto;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.spongycastle.crypto.digests.SHA512Digest;
import org.spongycastle.crypto.generators.PKCS5S2ParametersGenerator;
import org.spongycastle.crypto.params.KeyParameter;

public class MnemonicUtils {
    private static final int SEED_ITERATIONS = 2048;
    private static final int SEED_KEY_SIZE = 512;
    private static final SecureRandom secureRandom = SecureRandomUtils.secureRandom();
    private static List<String> WORD_LIST = null;

    public MnemonicUtils() {
    }

    public static String generateMnemonic(byte[] initialEntropy) {
        if (WORD_LIST == null) {
            WORD_LIST = populateWordList();
        }

        validateEntropy(initialEntropy);
        int ent = initialEntropy.length * 8;
        int checksumLength = ent / 32;
        byte checksum = calculateChecksum(initialEntropy);
        boolean[] bits = convertToBits(initialEntropy, checksum);
        int iterations = (ent + checksumLength) / 11;
        StringBuilder mnemonicBuilder = new StringBuilder();

        for(int i = 0; i < iterations; ++i) {
            int index = toInt(nextElevenBits(bits, i));
            mnemonicBuilder.append((String)WORD_LIST.get(index));
            boolean notLastIteration = i < iterations - 1;
            if (notLastIteration) {
                mnemonicBuilder.append(" ");
            }
        }

        return mnemonicBuilder.toString();
    }

    public static String generateNewMnemonic() {
        return generateMnemonic(generateNewEntropy());
    }

    public static byte[] generateNewEntropy() {
        byte[] initialEntropy = new byte[16];
        secureRandom.nextBytes(initialEntropy);
        return initialEntropy;
    }

    public static byte[] generateEntropy(String mnemonic) {
        if (WORD_LIST == null) {
            WORD_LIST = populateWordList();
        }

        if (isMnemonicEmpty(mnemonic)) {
            throw new IllegalArgumentException("Mnemonic is empty");
        } else {
            String bits = mnemonicToBits(mnemonic);
            int totalLength = bits.length();
            int ent = (int)Math.floor((double)(totalLength / 33)) * 32;
            String entropyBits = bits.substring(0, ent);
            String checksumBits = rightPad(bits.substring(ent), "0", 8);
            byte[] entropy = bitsToBytes(entropyBits);
            validateEntropy(entropy);
            byte newChecksum = calculateChecksum(entropy);
            if (newChecksum != (byte)Integer.parseInt(checksumBits, 2)) {
                throw new IllegalArgumentException("Checksum of mnemonic is invalid");
            } else {
                return entropy;
            }
        }
    }

    public static byte[] generateSeed(String mnemonic, String passphrase) {
        if (isMnemonicEmpty(mnemonic)) {
            throw new IllegalArgumentException("Mnemonic is required to generate a seed");
        } else {
            passphrase = passphrase == null ? "" : passphrase;
            String salt = String.format("mnemonic%s", passphrase);
            PKCS5S2ParametersGenerator gen = new PKCS5S2ParametersGenerator(new SHA512Digest());
            gen.init(mnemonic.getBytes(StandardCharsets.UTF_8), salt.getBytes(StandardCharsets.UTF_8), 2048);
            return ((KeyParameter)gen.generateDerivedParameters(512)).getKey();
        }
    }

    public static boolean validateMnemonic(String mnemonic) {
        try {
            generateEntropy(mnemonic);
            return true;
        } catch (Exception var2) {
            return false;
        }
    }

    private static boolean isMnemonicEmpty(String mnemonic) {
        return mnemonic == null || mnemonic.trim().isEmpty();
    }

    private static boolean[] nextElevenBits(boolean[] bits, int i) {
        int from = i * 11;
        int to = from + 11;
        return Arrays.copyOfRange(bits, from, to);
    }

    private static void validateEntropy(byte[] entropy) {
        if (entropy == null) {
            throw new IllegalArgumentException("Entropy is required");
        } else {
            int ent = entropy.length * 8;
            if (ent < 128 || ent > 256 || ent % 32 != 0) {
                throw new IllegalArgumentException("The allowed size of ENT is 128-256 bits of multiples of 32");
            }
        }
    }

    private static boolean[] convertToBits(byte[] initialEntropy, byte checksum) {
        int ent = initialEntropy.length * 8;
        int checksumLength = ent / 32;
        int totalLength = ent + checksumLength;
        boolean[] bits = new boolean[totalLength];

        int i;
        for(i = 0; i < initialEntropy.length; ++i) {
            for(int j = 0; j < 8; ++j) {
                byte b = initialEntropy[i];
                bits[8 * i + j] = toBit(b, j);
            }
        }

        for(i = 0; i < checksumLength; ++i) {
            bits[ent + i] = toBit(checksum, i);
        }

        return bits;
    }

    private static boolean toBit(byte value, int index) {
        return (value >>> 7 - index & 1) > 0;
    }

    private static int toInt(boolean[] bits) {
        int value = 0;

        for(int i = 0; i < bits.length; ++i) {
            boolean isSet = bits[i];
            if (isSet) {
                value += 1 << bits.length - i - 1;
            }
        }

        return value;
    }

    private static String mnemonicToBits(String mnemonic) {
        String[] words = mnemonic.split(" ");
        StringBuilder bits = new StringBuilder();
        String[] var3 = words;
        int var4 = words.length;

        for(int var5 = 0; var5 < var4; ++var5) {
            String word = var3[var5];
            int index = WORD_LIST.indexOf(word);
            if (index == -1) {
                throw new IllegalArgumentException(String.format("Mnemonic word '%s' should be in the word list", word));
            }

            bits.append(leftPad(Integer.toBinaryString(index), "0", 11));
        }

        return bits.toString();
    }

    private static byte[] bitsToBytes(String bits) {
        byte[] bytes = new byte[(int)Math.ceil((double)((float)bits.length() / 8.0F))];
        int index = 0;

        for(int iByte = 0; iByte < bytes.length; ++iByte) {
            String byteStr = bits.substring(index, Math.min(index + 8, bits.length()));
            bytes[iByte] = (byte)Integer.parseInt(byteStr, 2);
            index += 8;
        }

        return bytes;
    }

    private static String leftPad(String str, String padString, int length) {
        StringBuilder resultStr = new StringBuilder(str);

        while(resultStr.length() < length) {
            resultStr.insert(0, padString);
        }

        return resultStr.toString();
    }

    private static String rightPad(String str, String padString, int length) {
        StringBuilder resultStr = new StringBuilder(str);

        for(int i = str.length(); i < length; ++i) {
            resultStr.append(padString);
        }

        return resultStr.toString();
    }

    private static byte calculateChecksum(byte[] initialEntropy) {
        int ent = initialEntropy.length * 8;
        byte mask = (byte)(255 << 8 - ent / 32);
        byte[] bytes = Hash.sha256(initialEntropy);
        return (byte)(bytes[0] & mask);
    }

    private static List<String> populateWordList() {
        InputStream inputStream = Thread.currentThread().getContextClassLoader().getResourceAsStream("en-mnemonic-word-list.txt");

        try {
            return readAllLines(inputStream);
        } catch (Exception var2) {
            throw new IllegalStateException(var2);
        }
    }

    static List<String> readAllLines(InputStream inputStream) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
        ArrayList data = new ArrayList();

        String line;
        while((line = br.readLine()) != null) {
            data.add(line);
        }

        return data;
    }
}

