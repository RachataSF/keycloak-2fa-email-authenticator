package com.example.bouncechecker;

import jakarta.mail.*;
import jakarta.mail.search.FlagTerm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class BounceListenerService {

    @Value("${imap.host}")
    private String imapHost;

    @Value("${imap.username}")
    private String imapUsername;

    @Value("${imap.password}")
    private String imapPassword;

    // Cache to hold bounced emails for 10 minutes
    private final ConcurrentHashMap<String, Long> bounceCache = new ConcurrentHashMap<>();

    // Pattern to look for email addresses in the bounce message
    private static final Pattern BOUNCE_PATTERN = Pattern
            .compile("Your message wasn't delivered to\\s+([A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+)", Pattern.CASE_INSENSITIVE);

    @Scheduled(fixedRate = 5000) // Poll every 5 seconds
    public void pollInbox() {
        try {
            Properties props = new Properties();
            props.put("mail.store.protocol", "imaps");
            Session session = Session.getDefaultInstance(props, null);
            Store store = session.getStore("imaps");
            store.connect(imapHost, imapUsername, imapPassword);

            Folder inbox = store.getFolder("inbox");
            inbox.open(Folder.READ_WRITE);

            // Search for unread messages
            Message[] messages = inbox.search(new FlagTerm(new Flags(Flags.Flag.SEEN), false));
            System.out.println("Messages found: " + messages.length);
            System.out.println("Messages found: " + messages);
            for (Message message : messages) {
                Address[] froms = message.getFrom();
                if (froms != null && froms.length > 0) {
                    String from = froms[0].toString();
                    if (from.toLowerCase().contains("mailer-daemon")) {
                        Object content = message.getContent();
                        String body = "";
                        if (content instanceof String) {
                            body = (String) content;
                        } else if (content instanceof Multipart) {
                            body = getTextFromMimeMultipart((Multipart) content);
                        }

                        Matcher matcher = BOUNCE_PATTERN.matcher(body);
                        if (matcher.find()) {
                            String bouncedEmail = matcher.group(1);
                            // System.out.println("Detected bounce for: " + bouncedEmail);
                            // Store in cache with 10 minute TTL
                            bounceCache.put(bouncedEmail, System.currentTimeMillis() + 10 * 60 * 1000);
                        }
                    }
                }
                // Mark as read so we don't process it again
                message.setFlag(Flags.Flag.SEEN, true);
            }

            inbox.close(false);
            store.close();

            cleanCache();

        } catch (Exception e) {
            System.err.println("Error polling inbox: " + e.getMessage());
        }
    }

    private void cleanCache() {
        long now = System.currentTimeMillis();
        bounceCache.entrySet().removeIf(entry -> entry.getValue() < now);
    }

    public boolean hasBounced(String email) {
        return bounceCache.containsKey(email) && bounceCache.get(email) >= System.currentTimeMillis();
    }

    private String getTextFromMimeMultipart(Multipart mimeMultipart) throws Exception {
        StringBuilder result = new StringBuilder();
        int count = mimeMultipart.getCount();
        for (int i = 0; i < count; i++) {
            BodyPart bodyPart = mimeMultipart.getBodyPart(i);
            if (bodyPart.isMimeType("text/plain")) {
                result.append("\n").append(bodyPart.getContent());
                break; // without break same text appears twice
            } else if (bodyPart.isMimeType("text/html")) {
                String html = (String) bodyPart.getContent();
                result.append("\n").append(html);
            } else if (bodyPart.getContent() instanceof Multipart) {
                result.append(getTextFromMimeMultipart((Multipart) bodyPart.getContent()));
            }
        }
        return result.toString();
    }
}
